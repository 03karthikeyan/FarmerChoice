const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true
    },
    title: {
      type: String,
      required: true
    },
    body: {
      type: String,
      required: true
    },
    type: {
      type: String,
      enum: [
        'CHAT_MESSAGE',
        'DEAL_REQUEST',
        'DEAL_ACCEPTED',
        'DEAL_REJECTED',
        'DEAL_COUNTER',
        'DEAL_READY',
        'DEAL_COMPLETED',
        'REVIEW_RECEIVED',
        'FARMER_VERIFIED',
        'FEATURED_APPROVED',
        'SYSTEM_ANNOUNCEMENT'
      ],
      default: 'SYSTEM_ANNOUNCEMENT'
    },
    referenceId: {
      type: mongoose.Schema.Types.ObjectId
    },
    referenceType: {
      type: String,
      enum: ['Deal', 'Conversation', 'Vegetable', 'Review', 'User']
    },
    isRead: {
      type: Boolean,
      default: false
    }
  },
  {
    timestamps: true
  }
);

notificationSchema.index({ userId: 1, createdAt: -1 });

const Notification = mongoose.model('Notification', notificationSchema);

module.exports = Notification;
