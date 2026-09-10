const mongoose = require('mongoose');
const { MessageType } = require('../constants');

const messageSchema = new mongoose.Schema(
  {
    conversationId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Conversation',
      required: true
    },
    senderId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true
    },
    receiverId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true
    },
    text: {
      type: String,
      default: ''
    },
    messageType: {
      type: String,
      enum: Object.values(MessageType),
      default: MessageType.TEXT
    },
    imageUrl: {
      type: String,
      default: ''
    },
    dealOfferData: {
      quantity: Number,
      price: Number,
      unit: String,
      referenceValue: Number,
      vegetableName: String
    },
    isRead: {
      type: Boolean,
      default: false
    },
    readAt: {
      type: Date
    }
  },
  {
    timestamps: true
  }
);

messageSchema.index({ conversationId: 1, createdAt: 1 });
messageSchema.index({ receiverId: 1, isRead: 1 });

const Message = mongoose.model('Message', messageSchema);

module.exports = Message;
