const mongoose = require('mongoose');

const customerProfileSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      unique: true
    },
    villageOrTown: {
      type: String,
      required: [true, 'Village or Town is required'],
      trim: true
    },
    district: {
      type: String,
      required: [true, 'District is required'],
      trim: true
    },
    state: {
      type: String,
      required: [true, 'State is required'],
      default: 'Tamil Nadu',
      trim: true
    },
    defaultDeliveryAddress: {
      type: String,
      default: ''
    },
    location: {
      type: {
        type: String,
        enum: ['Point'],
        default: 'Point'
      },
      coordinates: {
        type: [Number], // [longitude, latitude]
        default: [79.1378, 10.7870]
      }
    },
    totalDealsRequested: {
      type: Number,
      default: 0
    },
    totalDealsCompleted: {
      type: Number,
      default: 0
    }
  },
  {
    timestamps: true
  }
);

customerProfileSchema.index({ location: '2dsphere' });

const CustomerProfile = mongoose.model('CustomerProfile', customerProfileSchema);

module.exports = CustomerProfile;
