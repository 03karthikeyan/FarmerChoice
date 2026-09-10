const mongoose = require('mongoose');

const reviewSchema = new mongoose.Schema(
  {
    dealId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Deal',
      required: true,
      unique: true // Exactly one review per deal
    },
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
      ref: 'Vegetable',
      required: true
    },
    rating: {
      type: Number,
      required: [true, 'Rating is required'],
      min: [1, 'Rating must be at least 1'],
      max: [5, 'Rating cannot exceed 5']
    },
    comment: {
      type: String,
      required: [true, 'Review comment is required'],
      trim: true
    },
    isVerifiedDeal: {
      type: Boolean,
      default: true // Calculated and enforced by backend
    },
    status: {
      type: String,
      enum: ['PUBLISHED', 'HIDDEN', 'FLAGGED'],
      default: 'PUBLISHED'
    },
    farmerReply: {
      type: String,
      default: ''
    },
    farmerRepliedAt: {
      type: Date
    }
  },
  {
    timestamps: true
  }
);

reviewSchema.index({ farmerId: 1, status: 1 });
reviewSchema.index({ vegetableId: 1 });

const Review = mongoose.model('Review', reviewSchema);

module.exports = Review;
