const User = require('../models/User');
const FarmerProfile = require('../models/FarmerProfile');
const CustomerProfile = require('../models/CustomerProfile');
const Vegetable = require('../models/Vegetable');
const Deal = require('../models/Deal');
const Review = require('../models/Review');
const Report = require('../models/Report');
const SupportTicket = require('../models/SupportTicket');
const AuditLog = require('../models/AuditLog');
const {
  UserRoles,
  UserStatus,
  FarmerVerificationStatus,
  FeaturedStatus,
  DealStatus
} = require('../constants');

// Log Admin Action
const logAdminAction = async (adminId, action, targetType, targetId, details, ip) => {
  try {
    await AuditLog.create({
      adminId,
      action,
      targetType,
      targetId,
      details,
      ipAddress: ip || ''
    });
  } catch (err) {
    console.error('Audit log failed:', err.message);
  }
};

// 1. Dashboard Metrics Overview
exports.getDashboardOverview = async (req, res, next) => {
  try {
    const [
      totalFarmers,
      verifiedFarmers,
      pendingFarmers,
      totalCustomers,
      activeVegetables,
      activeDeals,
      completedDeals,
      cancelledDeals,
      pendingReports,
      openTickets
    ] = await Promise.all([
      FarmerProfile.countDocuments(),
      FarmerProfile.countDocuments({ verificationStatus: FarmerVerificationStatus.VERIFIED }),
      FarmerProfile.countDocuments({ verificationStatus: FarmerVerificationStatus.PENDING }),
      CustomerProfile.countDocuments(),
      Vegetable.countDocuments({ status: 'ACTIVE' }),
      Deal.countDocuments({
        status: { $in: [DealStatus.REQUESTED, DealStatus.NEGOTIATING, DealStatus.ACCEPTED, DealStatus.READY] }
      }),
      Deal.countDocuments({ status: DealStatus.COMPLETED }),
      Deal.countDocuments({ status: DealStatus.CANCELLED }),
      Report.countDocuments({ status: 'PENDING' }),
      SupportTicket.countDocuments({ status: 'OPEN' })
    ]);

    const recentDeals = await Deal.find()
      .populate('farmerId', 'name phone profileImage')
      .populate('customerId', 'name phone profileImage')
      .populate('vegetableId', 'name price priceUnit')
      .sort({ createdAt: -1 })
      .limit(6);

    const pendingVerifications = await FarmerProfile.find({
      verificationStatus: FarmerVerificationStatus.PENDING
    })
      .populate('userId', 'name phone email createdAt')
      .limit(5);

    res.status(200).json({
      success: true,
      data: {
        stats: {
          totalFarmers,
          verifiedFarmers,
          pendingFarmers,
          totalCustomers,
          activeVegetables,
          activeDeals,
          completedDeals,
          cancelledDeals,
          pendingReports,
          openTickets
        },
        recentDeals,
        pendingVerifications
      }
    });
  } catch (error) {
    next(error);
  }
};

// 2. Farmer Management
exports.getFarmers = async (req, res, next) => {
  try {
    const { status, search, district, page = 1, limit = 20 } = req.query;
    const query = {};

    if (status && status !== 'All') {
      query.verificationStatus = status.toUpperCase();
    }
    if (district) {
      query.district = { $regex: district, $options: 'i' };
    }

    const skip = (Number(page) - 1) * Number(limit);

    const [farmers, total] = await Promise.all([
      FarmerProfile.find(query)
        .populate('userId', 'name phone email status profileImage isVerified createdAt lastLoginAt')
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(Number(limit)),
      FarmerProfile.countDocuments(query)
    ]);

    res.status(200).json({
      success: true,
      total,
      data: farmers
    });
  } catch (error) {
    next(error);
  }
};

// Verify Farmer
exports.verifyFarmer = async (req, res, next) => {
  try {
    const { id } = req.params;
    const adminId = req.user._id;

    const profile = await FarmerProfile.findById(id);
    if (!profile) {
      return res.status(404).json({ success: false, message: 'Farmer profile not found.' });
    }

    profile.verificationStatus = FarmerVerificationStatus.VERIFIED;
    profile.verifiedAt = new Date();
    profile.verifiedBy = adminId;
    if (!profile.badges.includes('Verified Farmer')) {
      profile.badges.push('Verified Farmer');
    }
    await profile.save();

    await User.findByIdAndUpdate(profile.userId, { isVerified: true });

    await logAdminAction(adminId, 'VERIFY_FARMER', 'FarmerProfile', profile._id, { verified: true }, req.ip);

    res.status(200).json({
      success: true,
      message: 'Farmer profile verified successfully.',
      data: profile
    });
  } catch (error) {
    next(error);
  }
};

// Reject Farmer
exports.rejectFarmer = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { reason } = req.body;
    const adminId = req.user._id;

    const profile = await FarmerProfile.findById(id);
    if (!profile) {
      return res.status(404).json({ success: false, message: 'Farmer profile not found.' });
    }

    profile.verificationStatus = FarmerVerificationStatus.REJECTED;
    await profile.save();

    await logAdminAction(adminId, 'REJECT_FARMER', 'FarmerProfile', profile._id, { reason }, req.ip);

    res.status(200).json({
      success: true,
      message: 'Farmer verification rejected.',
      data: profile
    });
  } catch (error) {
    next(error);
  }
};

// 3. User Suspension / Restoration
exports.toggleUserStatus = async (req, res, next) => {
  try {
    const { userId } = req.params;
    const { status, reason } = req.body;
    const adminId = req.user._id;

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found.' });
    }

    user.status = status === 'SUSPENDED' ? UserStatus.SUSPENDED : UserStatus.ACTIVE;
    await user.save();

    await logAdminAction(adminId, 'CHANGE_USER_STATUS', 'User', user._id, { newStatus: user.status, reason }, req.ip);

    res.status(200).json({
      success: true,
      message: `User status changed to ${user.status}.`,
      data: user
    });
  } catch (error) {
    next(error);
  }
};

// 4. Customer Management
exports.getCustomers = async (req, res, next) => {
  try {
    const { search, district, page = 1, limit = 20 } = req.query;
    const query = {};

    if (district) {
      query.district = { $regex: district, $options: 'i' };
    }

    const skip = (Number(page) - 1) * Number(limit);

    const [customers, total] = await Promise.all([
      CustomerProfile.find(query)
        .populate('userId', 'name phone email status profileImage isVerified createdAt lastLoginAt')
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(Number(limit)),
      CustomerProfile.countDocuments(query)
    ]);

    res.status(200).json({
      success: true,
      total,
      data: customers
    });
  } catch (error) {
    next(error);
  }
};

// 5. Vegetable Listings Moderation & Featured Management
exports.getVegetables = async (req, res, next) => {
  try {
    const { status, category, featuredStatus, search, page = 1, limit = 20 } = req.query;
    const query = {};

    if (status) query.status = status;
    if (category && category !== 'All') query.category = category;
    if (featuredStatus) query.featuredStatus = featuredStatus;
    if (search) {
      query.$or = [{ name: { $regex: search, $options: 'i' } }, { description: { $regex: search, $options: 'i' } }];
    }

    const skip = (Number(page) - 1) * Number(limit);

    const [vegetables, total] = await Promise.all([
      Vegetable.find(query)
        .populate('farmerId', 'name phone')
        .populate('farmerProfileId', 'farmName village district')
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(Number(limit)),
      Vegetable.countDocuments(query)
    ]);

    res.status(200).json({
      success: true,
      total,
      data: vegetables
    });
  } catch (error) {
    next(error);
  }
};

// Moderate / Approve Featured Vegetable
exports.moderateFeatured = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { approve, durationDays = 14 } = req.body;
    const adminId = req.user._id;

    const vegetable = await Vegetable.findById(id);
    if (!vegetable) {
      return res.status(404).json({ success: false, message: 'Vegetable not found.' });
    }

    if (approve) {
      vegetable.featuredStatus = FeaturedStatus.APPROVED;
      vegetable.featuredApprovedAt = new Date();
      const until = new Date();
      until.setDate(until.getDate() + Number(durationDays));
      vegetable.featuredUntil = until;
    } else {
      vegetable.featuredStatus = FeaturedStatus.REJECTED;
    }

    await vegetable.save();

    await logAdminAction(adminId, 'MODERATE_FEATURED', 'Vegetable', vegetable._id, { approve, durationDays }, req.ip);

    res.status(200).json({
      success: true,
      message: approve ? 'Vegetable approved as featured.' : 'Featured request rejected.',
      data: vegetable
    });
  } catch (error) {
    next(error);
  }
};

// 6. Review Moderation
exports.getReviews = async (req, res, next) => {
  try {
    const { status, page = 1, limit = 20 } = req.query;
    const query = {};
    if (status) query.status = status;

    const skip = (Number(page) - 1) * Number(limit);

    const [reviews, total] = await Promise.all([
      Review.find(query)
        .populate('customerId', 'name phone')
        .populate('farmerId', 'name phone')
        .populate('vegetableId', 'name')
        .populate('dealId', 'dealNumber status agreedQuantity agreedPrice dealReferenceValue')
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(Number(limit)),
      Review.countDocuments(query)
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

exports.moderateReview = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { status } = req.body; // 'PUBLISHED', 'HIDDEN', 'FLAGGED'
    const adminId = req.user._id;

    const review = await Review.findByIdAndUpdate(id, { status }, { new: true });
    if (!review) {
      return res.status(404).json({ success: false, message: 'Review not found.' });
    }

    await logAdminAction(adminId, 'MODERATE_REVIEW', 'Review', review._id, { newStatus: status }, req.ip);

    res.status(200).json({
      success: true,
      message: `Review marked as ${status}.`,
      data: review
    });
  } catch (error) {
    next(error);
  }
};

// 7. Report Management
exports.getReports = async (req, res, next) => {
  try {
    const { status, page = 1, limit = 20 } = req.query;
    const query = {};
    if (status) query.status = status;

    const skip = (Number(page) - 1) * Number(limit);

    const [reports, total] = await Promise.all([
      Report.find(query)
        .populate('reporterId', 'name phone role')
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(Number(limit)),
      Report.countDocuments(query)
    ]);

    res.status(200).json({
      success: true,
      total,
      data: reports
    });
  } catch (error) {
    next(error);
  }
};

exports.resolveReport = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { status, actionTaken } = req.body;
    const adminId = req.user._id;

    const report = await Report.findById(id);
    if (!report) {
      return res.status(404).json({ success: false, message: 'Report not found.' });
    }

    report.status = status || 'ACTIONED';
    report.actionTaken = actionTaken || 'Investigated and resolved';
    report.resolvedBy = adminId;
    report.resolvedAt = new Date();
    await report.save();

    await logAdminAction(adminId, 'RESOLVE_REPORT', 'Report', report._id, { status, actionTaken }, req.ip);

    res.status(200).json({
      success: true,
      message: 'Report status updated.',
      data: report
    });
  } catch (error) {
    next(error);
  }
};

// 8. Support Ticket Management
exports.getSupportTickets = async (req, res, next) => {
  try {
    const { status, page = 1, limit = 20 } = req.query;
    const query = {};
    if (status) query.status = status;

    const skip = (Number(page) - 1) * Number(limit);

    const [tickets, total] = await Promise.all([
      SupportTicket.find(query)
        .populate('userId', 'name phone email role')
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(Number(limit)),
      SupportTicket.countDocuments(query)
    ]);

    res.status(200).json({
      success: true,
      total,
      data: tickets
    });
  } catch (error) {
    next(error);
  }
};

exports.updateSupportTicket = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { status, adminNotes } = req.body;
    const adminId = req.user._id;

    const ticket = await SupportTicket.findById(id);
    if (!ticket) {
      return res.status(404).json({ success: false, message: 'Ticket not found.' });
    }

    if (status) ticket.status = status;
    if (adminNotes) ticket.adminNotes = adminNotes;
    if (status === 'RESOLVED' || status === 'CLOSED') {
      ticket.resolvedBy = adminId;
      ticket.resolvedAt = new Date();
    }
    await ticket.save();

    await logAdminAction(adminId, 'UPDATE_TICKET', 'SupportTicket', ticket._id, { status, adminNotes }, req.ip);

    res.status(200).json({
      success: true,
      message: 'Support ticket updated.',
      data: ticket
    });
  } catch (error) {
    next(error);
  }
};

// 9. Deals Monitoring
exports.getDeals = async (req, res, next) => {
  try {
    const { status, page = 1, limit = 20 } = req.query;
    const query = {};
    if (status) query.status = status;

    const skip = (Number(page) - 1) * Number(limit);

    const [deals, total] = await Promise.all([
      Deal.find(query)
        .populate('farmerId', 'name phone')
        .populate('customerId', 'name phone')
        .populate('vegetableId', 'name price priceUnit')
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(Number(limit)),
      Deal.countDocuments(query)
    ]);

    res.status(200).json({
      success: true,
      total,
      data: deals
    });
  } catch (error) {
    next(error);
  }
};

// 10. Audit Logs & Analytics
exports.getAuditLogs = async (req, res, next) => {
  try {
    const logs = await AuditLog.find()
      .populate('adminId', 'name email')
      .sort({ createdAt: -1 })
      .limit(100);

    res.status(200).json({
      success: true,
      count: logs.length,
      data: logs
    });
  } catch (error) {
    next(error);
  }
};
