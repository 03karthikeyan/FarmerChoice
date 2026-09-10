const mongoose = require('mongoose');
const { SupportCategories, SupportStatus } = require('../constants');

const supportTicketSchema = new mongoose.Schema(
  {
    ticketNumber: {
      type: String,
      unique: true,
      required: true
    },
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true
    },
    category: {
      type: String,
      enum: Object.values(SupportCategories),
      required: true
    },
    subject: {
      type: String,
      required: [true, 'Subject is required'],
      trim: true
    },
    description: {
      type: String,
      required: [true, 'Description is required'],
      trim: true
    },
    attachments: {
      type: [String],
      default: []
    },
    status: {
      type: String,
      enum: Object.values(SupportStatus),
      default: SupportStatus.OPEN
    },
    adminNotes: {
      type: String,
      default: ''
    },
    resolvedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    resolvedAt: {
      type: Date
    }
  },
  {
    timestamps: true
  }
);

supportTicketSchema.index({ userId: 1, status: 1 });
supportTicketSchema.index({ status: 1 });

const SupportTicket = mongoose.model('SupportTicket', supportTicketSchema);

module.exports = SupportTicket;
