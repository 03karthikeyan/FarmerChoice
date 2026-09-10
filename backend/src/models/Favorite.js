const mongoose = require('mongoose');

const favoriteSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true
    },
    targetType: {
      type: String,
      enum: ['VEGETABLE', 'FARMER'],
      required: true
    },
    targetId: {
      type: mongoose.Schema.Types.ObjectId,
      required: true,
      refPath: 'targetModel'
    },
    targetModel: {
      type: String,
      required: true,
      enum: ['Vegetable', 'User']
    }
  },
  {
    timestamps: true
  }
);

favoriteSchema.index({ userId: 1, targetType: 1, targetId: 1 }, { unique: true });

const Favorite = mongoose.model('Favorite', favoriteSchema);

module.exports = Favorite;
