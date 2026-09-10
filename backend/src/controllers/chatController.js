const Conversation = require('../models/Conversation');
const Message = require('../models/Message');
const User = require('../models/User');
const Vegetable = require('../models/Vegetable');
const { MessageType } = require('../constants');

// Get all conversations for current user
exports.getConversations = async (req, res, next) => {
  try {
    const userId = req.user._id;

    const conversations = await Conversation.find({
      $or: [{ customerId: userId }, { farmerId: userId }]
    })
      .populate('customerId', 'name phone profileImage isVerified')
      .populate('farmerId', 'name phone profileImage isVerified')
      .populate('vegetableId', 'name price priceUnit images')
      .populate('dealId', 'dealNumber status agreedQuantity agreedPrice dealReferenceValue')
      .sort({ updatedAt: -1 });

    res.status(200).json({
      success: true,
      count: conversations.length,
      data: conversations
    });
  } catch (error) {
    next(error);
  }
};

// Start or get conversation between customer & farmer
exports.createOrGetConversation = async (req, res, next) => {
  try {
    const userId = req.user._id;
    const { farmerId, customerId, vegetableId, dealId } = req.body;

    let targetCustomerId = req.user.role === 'CUSTOMER' ? userId : customerId;
    let targetFarmerId = req.user.role === 'FARMER' ? userId : farmerId;

    if (!targetCustomerId || !targetFarmerId) {
      return res.status(400).json({
        success: false,
        message: 'Both customerId and farmerId are required.'
      });
    }

    let conversation = await Conversation.findOne({
      customerId: targetCustomerId,
      farmerId: targetFarmerId
    })
      .populate('customerId', 'name phone profileImage isVerified')
      .populate('farmerId', 'name phone profileImage isVerified')
      .populate('vegetableId', 'name price priceUnit images')
      .populate('dealId');

    if (!conversation) {
      conversation = await Conversation.create({
        customerId: targetCustomerId,
        farmerId: targetFarmerId,
        vegetableId: vegetableId || null,
        dealId: dealId || null,
        lastMessage: {
          text: 'Conversation started',
          senderId: userId,
          createdAt: new Date()
        }
      });

      conversation = await Conversation.findById(conversation._id)
        .populate('customerId', 'name phone profileImage isVerified')
        .populate('farmerId', 'name phone profileImage isVerified')
        .populate('vegetableId', 'name price priceUnit images');
    }

    res.status(200).json({
      success: true,
      data: conversation
    });
  } catch (error) {
    next(error);
  }
};

// Get messages for a conversation
exports.getMessages = async (req, res, next) => {
  try {
    const { conversationId } = req.params;
    const userId = req.user._id;
    const { page = 1, limit = 50 } = req.query;

    const conversation = await Conversation.findById(conversationId);
    if (!conversation) {
      return res.status(404).json({ success: false, message: 'Conversation not found.' });
    }

    // Verify participant
    if (
      conversation.customerId.toString() !== userId.toString() &&
      conversation.farmerId.toString() !== userId.toString()
    ) {
      return res.status(403).json({ success: false, message: 'Unauthorized.' });
    }

    const skip = (Number(page) - 1) * Number(limit);

    const messages = await Message.find({ conversationId })
      .populate('senderId', 'name profileImage')
      .sort({ createdAt: 1 })
      .skip(skip)
      .limit(Number(limit));

    // Reset unread count for the receiver
    if (conversation.customerId.toString() === userId.toString()) {
      conversation.unreadCountCustomer = 0;
    } else {
      conversation.unreadCountFarmer = 0;
    }
    await conversation.save();

    res.status(200).json({
      success: true,
      count: messages.length,
      data: messages
    });
  } catch (error) {
    next(error);
  }
};

// Send message via REST
exports.sendMessage = async (req, res, next) => {
  try {
    const { conversationId } = req.params;
    const senderId = req.user._id;
    const { text, messageType = MessageType.TEXT, imageUrl, dealOfferData } = req.body;

    const conversation = await Conversation.findById(conversationId);
    if (!conversation) {
      return res.status(404).json({ success: false, message: 'Conversation not found.' });
    }

    const isCustomer = conversation.customerId.toString() === senderId.toString();
    const isFarmer = conversation.farmerId.toString() === senderId.toString();

    if (!isCustomer && !isFarmer) {
      return res.status(403).json({ success: false, message: 'Unauthorized.' });
    }

    const receiverId = isCustomer ? conversation.farmerId : conversation.customerId;

    const message = await Message.create({
      conversationId,
      senderId,
      receiverId,
      text: text || '',
      messageType,
      imageUrl: imageUrl || '',
      dealOfferData: dealOfferData || null,
      isRead: false
    });

    // Update conversation lastMessage & unread count
    conversation.lastMessage = {
      text: text || (imageUrl ? '📷 Photo' : 'New message'),
      senderId,
      createdAt: new Date()
    };

    if (isCustomer) {
      conversation.unreadCountFarmer += 1;
    } else {
      conversation.unreadCountCustomer += 1;
    }

    await conversation.save();

    const populated = await Message.findById(message._id).populate('senderId', 'name profileImage');

    res.status(201).json({
      success: true,
      data: populated
    });
  } catch (error) {
    next(error);
  }
};
