const mongoose = require('mongoose');
const { DealStatus, DeliveryMethod } = require('../constants');

const dealSchema = new mongoose.Schema(
  {
    dealNumber: {
      type: String,
      unique: true,
      required: true
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
    // Negotiation quantities & prices
    requestedQuantity: {
      type: Number,
      required: true,
      min: 0.1
    },
    agreedQuantity: {
      type: Number,
      required: true,
      min: 0.1
    },
    requestedPrice: {
      type: Number,
      required: true
    },
    agreedPrice: {
      type: Number,
      required: true
    },
    priceUnit: {
      type: String,
      default: 'kg'
    },
    dealReferenceValue: {
      type: Number,
      required: true
    },
    deliveryMethod: {
      type: String,
      enum: Object.values(DeliveryMethod),
      default: DeliveryMethod.PICKUP
    },
    deliveryAddress: {
      type: String,
      default: ''
    },
    preferredDate: {
      type: Date,
      default: Date.now
    },
    customerNote: {
      type: String,
      default: ''
    },
    farmerNote: {
      type: String,
      default: ''
    },
    lastCounterBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    counterHistory: [
      {
        proposedBy: {
          type: mongoose.Schema.Types.ObjectId,
          ref: 'User'
        },
        quantity: Number,
        price: Number,
        referenceValue: Number,
        preferredDate: Date,
        deliveryMethod: String,
        note: String,
        createdAt: {
          type: Date,
          default: Date.now
        }
      }
    ],
    status: {
      type: String,
      enum: Object.values(DealStatus),
      default: DealStatus.REQUESTED
    },
    customerConfirmed: {
      type: Boolean,
      default: false
    },
    farmerConfirmed: {
      type: Boolean,
      default: false
    },
    customerConfirmedAt: {
      type: Date
    },
    farmerConfirmedAt: {
      type: Date
    },
    completedAt: {
      type: Date
    },
    cancelledAt: {
      type: Date
    },
    cancellationReason: {
      type: String,
      default: ''
    },
    cancelledBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    hasReview: {
      type: Boolean,
      default: false
    },
    paymentDisclaimerAcknowledged: {
      type: Boolean,
      default: true // "Payment is made directly between customer and farmer. Farmer Choice does not process payments."
    }
  },
  {
    timestamps: true
  }
);

dealSchema.index({ customerId: 1, status: 1 });
dealSchema.index({ farmerId: 1, status: 1 });
dealSchema.index({ vegetableId: 1 });

const Deal = mongoose.model('Deal', dealSchema);

module.exports = Deal;
