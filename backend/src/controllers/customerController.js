const User = require('../models/User');
const CustomerProfile = require('../models/CustomerProfile');
const Deal = require('../models/Deal');
const Favorite = require('../models/Favorite');
const Review = require('../models/Review');
const Conversation = require('../models/Conversation');
const Message = require('../models/Message');

exports.getCustomerProfile = async (req, res, next) => {
  try {
    const profile = await CustomerProfile.findOne({ userId: req.user._id }).populate(
      'userId',
      'name phone email profileImage createdAt'
    );

    if (!profile) {
      return res.status(404).json({ success: false, message: 'Customer profile not found.' });
    }

    const [totalDealsRequested, totalDealsCompleted, favoritesCount] = await Promise.all([
      Deal.countDocuments({ customerId: req.user._id }),
      Deal.countDocuments({ customerId: req.user._id, status: 'COMPLETED' }),
      Favorite.countDocuments({ userId: req.user._id })
    ]);

    res.status(200).json({
      success: true,
      data: {
        profile,
        stats: {
          totalDealsRequested,
          totalDealsCompleted,
          favoritesCount
        }
      }
    });
  } catch (error) {
    next(error);
  }
};

// Update customer profile
exports.updateCustomerProfile = async (req, res, next) => {
  try {
    const { name, email, phone, profileImage, villageOrTown, district, state } = req.body;

    const user = await User.findById(req.user._id);
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found.' });
    }

    if (name) user.name = name.trim();
    if (email !== undefined) user.email = email.trim();
    if (phone) user.phone = phone.trim();
    if (profileImage !== undefined) user.profileImage = profileImage;
    await user.save();

    let profile = await CustomerProfile.findOne({ userId: req.user._id });
    if (profile) {
      if (villageOrTown !== undefined) profile.villageOrTown = villageOrTown.trim();
      if (district !== undefined) profile.district = district.trim();
      if (state !== undefined) profile.state = state.trim();
      await profile.save();
    }

    res.status(200).json({
      success: true,
      message: 'Profile updated successfully.',
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

// Delete customer account
exports.deleteCustomerAccount = async (req, res, next) => {
  try {
    const userId = req.user._id;

    // Delete user and associated records
    await Promise.all([
      User.findByIdAndDelete(userId),
      CustomerProfile.findOneAndDelete({ userId }),
      Favorite.deleteMany({ userId }),
      Review.deleteMany({ customerId: userId }),
      Deal.deleteMany({ customerId: userId }),
      Conversation.deleteMany({ customerId: userId }),
      Message.deleteMany({ senderId: userId })
    ]);

    res.status(200).json({
      success: true,
      message: 'Your account has been deleted successfully.'
    });
  } catch (error) {
    next(error);
  }
};
