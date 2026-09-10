const mongoose = require('mongoose');
const { FarmerVerificationStatus } = require('../constants');

const farmerProfileSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      unique: true
    },
    farmName: {
      type: String,
      trim: true,
      default: ''
    },
    village: {
      type: String,
      required: [true, 'Village is required'],
      trim: true
    },
    taluk: {
      type: String,
      trim: true,
      default: ''
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
    farmAddress: {
      type: String,
      required: [true, 'Farm address is required'],
      trim: true
    },
    location: {
      type: {
        type: String,
        enum: ['Point'],
        default: 'Point'
      },
      coordinates: {
        type: [Number], // [longitude, latitude]
        default: [79.1378, 10.7870] // Default Thanjavur
      }
    },
    farmPhotos: {
      type: [String],
      default: []
    },
    aboutMe: {
      type: String,
      default: 'Experienced farmer providing naturally grown fresh vegetables directly from farm to customers.'
    },
    farmingExperienceYears: {
      type: Number,
      default: 5
    },
    verificationStatus: {
      type: String,
      enum: Object.values(FarmerVerificationStatus),
      default: FarmerVerificationStatus.PENDING
    },
    verifiedAt: {
      type: Date
    },
    verifiedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    rating: {
      type: Number,
      default: 5.0,
      min: 0,
      max: 5
    },
    totalReviews: {
      type: Number,
      default: 0
    },
    completedDealsCount: {
      type: Number,
      default: 0
    },
    totalDealsCount: {
      type: Number,
      default: 0
    },
    isOrganicCertified: {
      type: Boolean,
      default: true
    },
    badges: {
      type: [String],
      default: ['Farm Fresh', 'Direct Farmer']
    },
    allowFarmVisit: {
      type: Boolean,
      default: true
    }
  },
  {
    timestamps: true
  }
);

farmerProfileSchema.index({ location: '2dsphere' });
farmerProfileSchema.index({ district: 1, village: 1 });

const FarmerProfile = mongoose.model('FarmerProfile', farmerProfileSchema);

module.exports = FarmerProfile;
