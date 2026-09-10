const mongoose = require('mongoose');
const { VegetableCategories, AvailabilityStatus, FeaturedStatus } = require('../constants');

const vegetableSchema = new mongoose.Schema(
  {
    farmerId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true
    },
    farmerProfileId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'FarmerProfile',
      required: true
    },
    name: {
      type: String,
      required: [true, 'Vegetable name is required'],
      trim: true
    },
    tamilName: {
      type: String,
      default: '',
      trim: true
    },
    category: {
      type: String,
      enum: Object.values(VegetableCategories),
      default: VegetableCategories.VEGETABLE,
      required: true
    },
    images: {
      type: [String],
      default: []
    },
    description: {
      type: String,
      default: ''
    },
    price: {
      type: Number,
      required: [true, 'Price is required'],
      min: [1, 'Price must be greater than 0']
    },
    priceUnit: {
      type: String,
      default: 'kg', // kg, bunch, piece, sack
      trim: true
    },
    availableQuantity: {
      type: Number,
      required: [true, 'Available quantity is required'],
      min: [0, 'Quantity cannot be negative'],
      default: 0
    },
    minOrderQuantity: {
      type: Number,
      default: 1
    },
    availabilityStatus: {
      type: String,
      enum: Object.values(AvailabilityStatus),
      default: AvailabilityStatus.AVAILABLE_NOW
    },
    availableFrom: {
      type: Date,
      default: Date.now
    },
    availableUntil: {
      type: Date
    },
    harvestDate: {
      type: Date
    },
    isOrganic: {
      type: Boolean,
      default: true
    },
    featuredStatus: {
      type: String,
      enum: Object.values(FeaturedStatus),
      default: FeaturedStatus.NONE
    },
    featuredRequestedAt: {
      type: Date
    },
    featuredApprovedAt: {
      type: Date
    },
    featuredUntil: {
      type: Date
    },
    status: {
      type: String,
      enum: ['ACTIVE', 'HIDDEN', 'SUSPENDED'],
      default: 'ACTIVE'
    },
    viewCount: {
      type: Number,
      default: 0
    },
    inquiryCount: {
      type: Number,
      default: 0
    }
  },
  {
    timestamps: true
  }
);

vegetableSchema.index({ name: 'text', description: 'text', tamilName: 'text' });
vegetableSchema.index({ category: 1, status: 1, availabilityStatus: 1 });
vegetableSchema.index({ farmerId: 1 });
vegetableSchema.index({ price: 1 });
vegetableSchema.index({ featuredStatus: 1 });

const Vegetable = mongoose.model('Vegetable', vegetableSchema);

module.exports = Vegetable;
