const Favorite = require('../models/Favorite');

// Toggle Favorite (Add / Remove)
exports.toggleFavorite = async (req, res, next) => {
  try {
    const userId = req.user._id;
    const { targetType, targetId } = req.body;

    if (!targetType || !targetId) {
      return res.status(400).json({ success: false, message: 'targetType and targetId are required.' });
    }

    const targetModel = targetType === 'VEGETABLE' ? 'Vegetable' : 'User';

    const existing = await Favorite.findOne({ userId, targetType, targetId });

    if (existing) {
      await Favorite.findByIdAndDelete(existing._id);
      return res.status(200).json({
        success: true,
        isFavorited: false,
        message: 'Removed from favorites.'
      });
    } else {
      await Favorite.create({
        userId,
        targetType,
        targetId,
        targetModel
      });
      return res.status(201).json({
        success: true,
        isFavorited: true,
        message: 'Added to favorites.'
      });
    }
  } catch (error) {
    next(error);
  }
};

// Get My Favorites
exports.getMyFavorites = async (req, res, next) => {
  try {
    const userId = req.user._id;
    const { targetType } = req.query;

    const query = { userId };
    if (targetType) query.targetType = targetType;

    const favorites = await Favorite.find(query)
      .populate('targetId')
      .sort({ createdAt: -1 });

    res.status(200).json({
      success: true,
      count: favorites.length,
      data: favorites
    });
  } catch (error) {
    next(error);
  }
};
