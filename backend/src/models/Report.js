const mongoose = require('mongoose');
const { ReportReasons, ReportStatus } = require('../constants');

const reportSchema = new mongoose.Schema(
  {
    reporterId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true
    },
    targetType: {
      type: String,
      enum: ['USER', 'VEGETABLE', 'REVIEW', 'DEAL'],
      required: true
    },
    targetId: {
      type: mongoose.Schema.Types.ObjectId,
      required: true
    },
    reason: {
      type: String,
      enum: Object.values(ReportReasons),
      required: true
    },
    description: {
      type: String,
      required: [true, 'Description is required'],
      trim: true
    },
    evidenceImages: {
      type: [String],
      default: []
    },
    status: {
      type: String,
      enum: Object.values(ReportStatus),
      default: ReportStatus.PENDING
    },
    actionTaken: {
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

reportSchema.index({ status: 1, createdAt: -1 });

const Report = mongoose.model('Report', reportSchema);

module.exports = Report;
