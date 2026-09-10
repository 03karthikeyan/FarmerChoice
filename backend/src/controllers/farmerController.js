const FarmerProfile = require('../models/FarmerProfile');
const User = require('../models/User');
const Vegetable = require('../models/Vegetable');
const Deal = require('../models/Deal');
const Review = require('../models/Review');
const Conversation = require('../models/Conversation');
const Message = require('../models/Message');
const Favorite = require('../models/Favorite');
const { DealStatus, FarmerVerificationStatus } = require('../constants');

// List farmers (with district filter, verification status filter, sort by rating/deals)
exports.getFarmers = async (req, res, next) => {
  try {
    const { district, isVerified, sortBy = 'rating', page = 1, limit = 20 } = req.query;
    const query = {};

    if (district) {
      query.district = { $regex: district, $options: 'i' };
    }

    if (isVerified === 'true') {
      query.verificationStatus = FarmerVerificationStatus.VERIFIED;
    }

    let sort = { rating: -1, completedDealsCount: -1 };
    if (sortBy === 'completedDeals') sort = { completedDealsCount: -1 };
    if (sortBy === 'newest') sort = { createdAt: -1 };

    const skip = (Number(page) - 1) * Number(limit);

    const [profiles, total] = await Promise.all([
      FarmerProfile.find(query)
        .populate({
          path: 'userId',
          select: 'name phone profileImage isVerified createdAt'
        })
        .sort(sort)
        .skip(skip)
        .limit(Number(limit)),
      FarmerProfile.countDocuments(query)
    ]);

    res.status(200).json({
      success: true,
      total,
      page: Number(page),
      totalPages: Math.ceil(total / Number(limit)),
      data: profiles
    });
  } catch (error) {
    next(error);
  }
};

// Get single farmer public profile
exports.getFarmerProfile = async (req, res, next) => {
  try {
    const { id } = req.params;

    // Search by either User ID or FarmerProfile ID
    let profile = await FarmerProfile.findOne({
      $or: [{ _id: id.match(/^[0-9a-fA-F]{24}$/) ? id : null }, { userId: id.match(/^[0-9a-fA-F]{24}$/) ? id : null }]
    }).populate('userId', 'name phone profileImage isVerified createdAt');

    if (!profile) {
      return res.status(404).json({ success: false, message: 'Farmer not found.' });
    }

    // Get active vegetables listed by this farmer
    const vegetables = await Vegetable.find({
      farmerId: profile.userId._id,
      status: 'ACTIVE'
    });

    // Get verified reviews
    const reviews = await Review.find({
      farmerId: profile.userId._id,
      status: 'PUBLISHED'
    })
      .populate('customerId', 'name profileImage')
      .populate('vegetableId', 'name')
      .sort({ createdAt: -1 })
      .limit(10);

    res.status(200).json({
      success: true,
      data: {
        profile,
        vegetables,
        reviews
      }
    });
  } catch (error) {
    next(error);
  }
};

// Farmer Dashboard Summary (for the logged in farmer)
exports.getDashboardStats = async (req, res, next) => {
  try {
    const farmerId = req.user._id;

    const [
      totalProducts,
      availableProducts,
      newRequests,
      activeDeals,
      completedDeals,
      recentDeals,
      profile
    ] = await Promise.all([
      Vegetable.countDocuments({ farmerId }),
      Vegetable.countDocuments({ farmerId, availabilityStatus: 'AVAILABLE_NOW' }),
      Deal.countDocuments({ farmerId, status: DealStatus.REQUESTED }),
      Deal.countDocuments({
        farmerId,
        status: { $in: [DealStatus.REQUESTED, DealStatus.NEGOTIATING, DealStatus.ACCEPTED, DealStatus.READY] }
      }),
      Deal.countDocuments({ farmerId, status: DealStatus.COMPLETED }),
      Deal.find({ farmerId })
        .populate('customerId', 'name phone profileImage')
        .populate('vegetableId', 'name price priceUnit images')
        .sort({ updatedAt: -1 })
        .limit(5),
      FarmerProfile.findOne({ userId: farmerId })
    ]);

    res.status(200).json({
      success: true,
      data: {
        totalProducts,
        availableProducts,
        newRequests,
        activeDeals,
        completedDeals,
        rating: profile ? profile.rating : 5.0,
        totalReviews: profile ? profile.totalReviews : 0,
        verificationStatus: profile ? profile.verificationStatus : 'PENDING',
        recentDeals
      }
    });
  } catch (error) {
    next(error);
  }
};

// Update farmer profile
exports.updateFarmerProfile = async (req, res, next) => {
  try {
    const farmerId = req.user._id;
    const {
      name,
      email,
      phone,
      profileImage,
      farmName,
      farmAddress,
      village,
      taluk,
      district,
      state,
      aboutMe,
      allowFarmVisit,
      farmPhotos
    } = req.body;

    const user = await User.findById(farmerId);
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found.' });
    }

    if (name) user.name = name.trim();
    if (email !== undefined) user.email = email.trim();
    if (phone) user.phone = phone.trim();
    if (profileImage !== undefined) user.profileImage = profileImage;
    await user.save();

    let profile = await FarmerProfile.findOne({ userId: farmerId });
    if (profile) {
      if (farmName !== undefined) profile.farmName = farmName.trim();
      if (farmAddress !== undefined) profile.farmAddress = farmAddress.trim();
      if (village !== undefined) profile.village = village.trim();
      if (taluk !== undefined) profile.taluk = taluk.trim();
      if (district !== undefined) profile.district = district.trim();
      if (state !== undefined) profile.state = state.trim();
      if (aboutMe !== undefined) profile.aboutMe = aboutMe.trim();
      if (allowFarmVisit !== undefined) profile.allowFarmVisit = allowFarmVisit;
      if (farmPhotos !== undefined && Array.isArray(farmPhotos)) profile.farmPhotos = farmPhotos;
      await profile.save();
    }

    res.status(200).json({
      success: true,
      message: 'Farmer profile updated successfully.',
      data: {
        user: {
          id: user._id,
          name: user.name,
          phone: user.phone,
          email: user.email,
          role: user.role,
          profileImage: user.profileImage,
          status: user.status
        },
        profile
      }
    });
  } catch (error) {
    next(error);
  }
};

// Delete farmer account
exports.deleteFarmerAccount = async (req, res, next) => {
  try {
    const farmerId = req.user._id;

    // Delete user, farmer profile, products, deals, reviews
    await Promise.all([
      User.findByIdAndDelete(farmerId),
      FarmerProfile.findOneAndDelete({ userId: farmerId }),
      Vegetable.deleteMany({ farmerId }),
      Deal.deleteMany({ farmerId }),
      Review.deleteMany({ farmerId }),
      Favorite.deleteMany({ userId: farmerId }),
      Conversation.deleteMany({ farmerId }),
      Message.deleteMany({ senderId: farmerId })
    ]);

    res.status(200).json({
      success: true,
      message: 'Farmer account and all associated listings have been deleted successfully.'
    });
  } catch (error) {
    next(error);
  }
};
