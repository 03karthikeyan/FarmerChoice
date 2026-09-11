const jwt = require('jsonwebtoken');
const Message = require('../models/Message');
const Conversation = require('../models/Conversation');
const User = require('../models/User');
const notificationService = require('../services/notificationService');

const setupChatSocket = (io) => {
  // Authentication middleware for socket connections
  io.use(async (socket, next) => {
    try {
      const token = socket.handshake.auth?.token || socket.handshake.headers?.authorization?.split(' ')[1];
      if (!token) {
        return next(new Error('Authentication token required'));
      }

      const decoded = jwt.verify(
        token,
        process.env.JWT_SECRET || 'farmer_choice_super_secret_jwt_key_2026_secure'
      );
      const user = await User.findById(decoded.id);

      if (!user) {
        return next(new Error('User not found'));
      }

      socket.user = user;
      next();
    } catch (err) {
      next(new Error('Authentication failed: ' + err.message));
    }
  });

  const onlineUsers = new Map(); // userId -> socketId

  io.on('connection', (socket) => {
    const userId = socket.user._id.toString();
    onlineUsers.set(userId, socket.id);
    io.emit('user_presence', { userId, status: 'ONLINE' });

    console.log(`[Socket] User connected: ${socket.user.name} (${userId})`);

    // Join personal user room for direct push notifications
    socket.join(`user:${userId}`);

    // Join specific conversation room
    socket.on('join_conversation', async ({ conversationId }) => {
      try {
        const conversation = await Conversation.findById(conversationId);
        if (!conversation) return;

        // Security check: only participants can join
        const isParticipant =
          conversation.customerId.toString() === userId || conversation.farmerId.toString() === userId;

        if (isParticipant) {
          socket.join(`conversation:${conversationId}`);
        }
      } catch (err) {
        console.error('Socket join_conversation error:', err.message);
      }
    });

    // Leave conversation room
    socket.on('leave_conversation', ({ conversationId }) => {
      socket.leave(`conversation:${conversationId}`);
    });

    // Send Message
    socket.on('send_message', async (data, callback) => {
      try {
        const { conversationId, text, imageUrl, messageType = 'TEXT', dealOfferData } = data;

        const conversation = await Conversation.findById(conversationId);
        if (!conversation) {
          if (callback) callback({ success: false, error: 'Conversation not found' });
          return;
        }

        const isCustomer = conversation.customerId.toString() === userId;
        const isFarmer = conversation.farmerId.toString() === userId;

        if (!isCustomer && !isFarmer) {
          if (callback) callback({ success: false, error: 'Unauthorized' });
          return;
        }

        const receiverId = isCustomer ? conversation.farmerId : conversation.customerId;

        const message = await Message.create({
          conversationId,
          senderId: userId,
          receiverId,
          text: text || '',
          imageUrl: imageUrl || '',
          messageType,
          dealOfferData: dealOfferData || null,
          isRead: false
        });

        // Update conversation summary
        conversation.lastMessage = {
          text: text || (imageUrl ? '📷 Photo' : 'New message'),
          senderId: userId,
          createdAt: new Date()
        };

        if (isCustomer) {
          conversation.unreadCountFarmer += 1;
        } else {
          conversation.unreadCountCustomer += 1;
        }
        await conversation.save();

        const populatedMessage = await Message.findById(message._id).populate('senderId', 'name profileImage');

        // Broadcast to the conversation room
        io.to(`conversation:${conversationId}`).emit('new_message', populatedMessage);

        // Also notify the receiver's private room
        io.to(`user:${receiverId.toString()}`).emit('message_notification', {
          conversationId,
          message: populatedMessage
        });

        // Send background/foreground push notification via Firebase FCM
        const senderName = socket.user.name || 'FarmerChoice';
        notificationService.sendPushNotification({
          userId: receiverId,
          title: `💬 New message from ${senderName}`,
          body: text || (imageUrl ? '📷 Sent a photo' : 'Sent an attachment'),
          data: {
            type: 'CHAT_MESSAGE',
            conversationId: String(conversationId),
            senderId: String(userId),
            messageId: String(message._id)
          }
        }).catch(err => console.log('Chat push err:', err.message));

        if (callback) callback({ success: true, data: populatedMessage });
      } catch (err) {
        console.error('Socket send_message error:', err.message);
        if (callback) callback({ success: false, error: err.message });
      }
    });

    // Typing indicators
    socket.on('typing', ({ conversationId }) => {
      socket.to(`conversation:${conversationId}`).emit('user_typing', {
        conversationId,
        userId
      });
    });

    socket.on('stop_typing', ({ conversationId }) => {
      socket.to(`conversation:${conversationId}`).emit('user_stop_typing', {
        conversationId,
        userId
      });
    });

    // Read receipt
    socket.on('mark_read', async ({ conversationId, messageIds }) => {
      try {
        await Message.updateMany(
          { conversationId, receiverId: userId, isRead: false },
          { isRead: true, readAt: new Date() }
        );
        socket.to(`conversation:${conversationId}`).emit('messages_read', {
          conversationId,
          readBy: userId
        });
      } catch (err) {
        console.error('Socket mark_read error:', err.message);
      }
    });

    // Disconnect
    socket.on('disconnect', () => {
      onlineUsers.delete(userId);
      io.emit('user_presence', { userId, status: 'OFFLINE' });
      console.log(`[Socket] User disconnected: ${userId}`);
    });
  });
};

module.exports = setupChatSocket;
