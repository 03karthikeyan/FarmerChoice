const Review = require('../models/Review');
const Deal = require('../models/Deal');
const FarmerProfile = require('../models/FarmerProfile');
const notificationService = require('../services/notificationService');
const { DealStatus } = require('../constants');

// Submit Verified Review
exports.createReview = async (req, res, next) => {
  try {
    const customerId = req.user._id;
    const { dealId, rating, comment } = req.body;

    if (!dealId || !rating || !comment) {
      return res.status(400).json({
        success: false,
        message: 'Deal ID, rating (1-5), and review comment are required.'
      });
    }

    // 1. Fetch deal and strictly verify
    const deal = await Deal.findById(dealId);
    if (!deal) {
      return res.status(404).json({
        success: false,
        message: 'Deal not found.'
      });
    }

    // 2. Prevent review if deal is NOT completed
    if (deal.status !== DealStatus.COMPLETED) {
      return res.status(400).json({
        success: false,
        message: 'A verified review can only be submitted after the deal is COMPLETED.'
      });
    }

    // 3. Prevent self-review or review by another user
    if (deal.customerId.toString() !== customerId.toString()) {
      return res.status(403).json({
        success: false,
        message: 'You can only review deals where you were the customer.'
      });
    }

    // 4. Prevent duplicate review
    const existingReview = await Review.findOne({ dealId });
    if (existingReview) {
      return res.status(400).json({
        success: false,
        message: 'You have already submitted a review for this completed deal.'
      });
    }

    const numRating = Number(rating);
    if (numRating < 1 || numRating > 5) {
      return res.status(400).json({
        success: false,
        message: 'Rating must be between 1 and 5 stars.'
      });
    }

    // 5. Create verified review
    const review = await Review.create({
      dealId: deal._id,
      customerId,
      farmerId: deal.farmerId,
      vegetableId: deal.vegetableId,
      rating: numRating,
      comment: comment.trim(),
      isVerifiedDeal: true, // Backend-calculated guarantee
      status: 'PUBLISHED'
    });

    // 6. Mark deal as reviewed
    deal.hasReview = true;
    await deal.save();

    // 7. Recalculate Farmer's average rating & total reviews
    const allReviews = await Review.find({ farmerId: deal.farmerId, status: 'PUBLISHED' });
    const totalReviews = allReviews.length;
    const avgRating = allReviews.reduce((sum, r) => sum + r.rating, 0) / totalReviews;

    await FarmerProfile.findOneAndUpdate(
      { userId: deal.farmerId },
      {
        rating: Math.round(avgRating * 10) / 10,
        totalReviews
      }
    );

    const populated = await Review.findById(review._id)
      .populate('customerId', 'name profileImage')
      .populate('vegetableId', 'name');

    // Notify farmer of new verified review
    await notificationService.sendNotification({
      userId: deal.farmerId,
      title: 'New Verified Review! ⭐',
      body: `A customer gave you a ${numRating}-star review for deal #${deal.dealNumber}`,
      type: 'REVIEW_RECEIVED',
      referenceId: review._id,
      referenceType: 'Review',
      data: { reviewId: review._id.toString(), farmerId: deal.farmerId.toString() }
    });

    res.status(201).json({
      success: true,
      message: 'Verified review submitted successfully. Thank you for supporting our farmers!',
      data: populated
    });
  } catch (error) {
    next(error);
  }
};

// Get reviews for a farmer
exports.getFarmerReviews = async (req, res, next) => {
  try {
    const { farmerId } = req.params;
    const { page = 1, limit = 20 } = req.query;

    const skip = (Number(page) - 1) * Number(limit);

    const [reviews, total] = await Promise.all([
      Review.find({ farmerId, status: 'PUBLISHED' })
        .populate('customerId', 'name profileImage')
        .populate('vegetableId', 'name priceUnit')
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(Number(limit)),
      Review.countDocuments({ farmerId, status: 'PUBLISHED' })
    ]);

    res.status(200).json({
      success: true,
      total,
      data: reviews
    });
  } catch (error) {
    next(error);
  }
};

// Farmer: Reply to review
exports.replyToReview = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { reply } = req.body;
    const farmerId = req.user._id;

    const review = await Review.findById(id);
    if (!review || review.farmerId.toString() !== farmerId.toString()) {
      return res.status(404).json({ success: false, message: 'Review not found or unauthorized.' });
    }

    review.farmerReply = reply;
    review.farmerRepliedAt = new Date();
    await review.save();

    // Notify customer of farmer reply
    await notificationService.sendNotification({
      userId: review.customerId,
      title: 'Farmer Replied to Your Review 💬',
      body: `The farmer replied: "${reply.slice(0, 80)}${reply.length > 80 ? '...' : ''}"`,
      type: 'REVIEW_REPLIED',
      referenceId: review._id,
      referenceType: 'Review',
      data: { reviewId: review._id.toString() }
    });

    res.status(200).json({
      success: true,
      message: 'Reply posted.',
      data: review
    });
  } catch (error) {
    next(error);
  }
};

// Customer: Check if eligible to review a farmer (must have completed un-reviewed deal)
exports.checkReviewEligibility = async (req, res, next) => {
  try {
    const customerId = req.user._id;
    const { farmerId } = req.params;

    // Find any completed deal with this farmer where customer hasn't submitted a review yet
    const completedDeal = await Deal.findOne({
      customerId,
      farmerId,
      status: DealStatus.COMPLETED,
      hasReview: false
    })
      .populate('vegetableId', 'name priceUnit images')
      .populate('farmerId', 'name profileImage')
      .sort({ updatedAt: -1 });

    if (!completedDeal) {
      return res.status(200).json({
        success: true,
        canReview: false,
        message: 'Verified reviews are only accessible after completing and confirming a direct deal.'
      });
    }

    res.status(200).json({
      success: true,
      canReview: true,
      deal: completedDeal
    });
  } catch (error) {
    next(error);
  }
};
