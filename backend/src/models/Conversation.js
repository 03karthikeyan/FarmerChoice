const mongoose = require('mongoose');

const conversationSchema = new mongoose.Schema(
  {
    customerId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true
    },
    farmerId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true
    },
    vegetableId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Vegetable'
    },
    dealId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Deal'
    },
    lastMessage: {
      text: { type: String, default: '' },
      senderId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
      createdAt: { type: Date, default: Date.now }
    },
    unreadCountCustomer: {
      type: Number,
      default: 0
    },
    unreadCountFarmer: {
      type: Number,
      default: 0
    },
    isBlocked: {
      type: Boolean,
      default: false
    },
    blockedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    }
  },
  {
    timestamps: true
  }
);

conversationSchema.index({ customerId: 1, farmerId: 1 });
conversationSchema.index({ updatedAt: -1 });

const Conversation = mongoose.model('Conversation', conversationSchema);

module.exports = Conversation;
