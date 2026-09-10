const Deal = require('../models/Deal');
const Vegetable = require('../models/Vegetable');
const FarmerProfile = require('../models/FarmerProfile');
const CustomerProfile = require('../models/CustomerProfile');
const Notification = require('../models/Notification');
const User = require('../models/User');
const { DealStatus, DeliveryMethod, UserRoles } = require('../constants');

// Helper to generate readable deal number like #FC1024
const generateDealNumber = async () => {
  const count = await Deal.countDocuments();
  const randomSuffix = Math.floor(1000 + Math.random() * 9000);
  return `FC${1000 + count + 1}`;
};

// Customer: Create a direct deal request
exports.createDealRequest = async (req, res, next) => {
  try {
    const customerId = req.user._id;
    const {
      vegetableId,
      requestedQuantity,
      requestedPrice,
      preferredDate,
      deliveryMethod = DeliveryMethod.PICKUP,
      deliveryAddress,
      customerNote
    } = req.body;

    if (!vegetableId || !requestedQuantity || !requestedPrice) {
      return res.status(400).json({
        success: false,
        message: 'Vegetable, quantity, and reference price are required.'
      });
    }

    const vegetable = await Vegetable.findById(vegetableId);
    if (!vegetable || vegetable.status !== 'ACTIVE') {
      return res.status(404).json({
        success: false,
        message: 'Vegetable is currently not available.'
      });
    }

    // Safety check: Cannot create deal with yourself
    if (vegetable.farmerId.toString() === customerId.toString()) {
      return res.status(400).json({
        success: false,
        message: 'You cannot create a deal with yourself.'
      });
    }

    const dealNumber = await generateDealNumber();
    const qty = Number(requestedQuantity);
    const price = Number(requestedPrice);
    const refValue = Math.round(qty * price * 100) / 100;

    const deal = await Deal.create({
      dealNumber,
      customerId,
      farmerId: vegetable.farmerId,
      vegetableId: vegetable._id,
      requestedQuantity: qty,
      agreedQuantity: qty,
      requestedPrice: price,
      agreedPrice: price,
      priceUnit: vegetable.priceUnit || 'kg',
      dealReferenceValue: refValue,
      deliveryMethod,
      deliveryAddress: deliveryAddress || '',
      preferredDate: preferredDate || new Date(),
      customerNote: customerNote || '',
      lastCounterBy: customerId,
      status: DealStatus.REQUESTED,
      counterHistory: [
        {
          proposedBy: customerId,
          quantity: qty,
          price: price,
          referenceValue: refValue,
          preferredDate: preferredDate || new Date(),
          deliveryMethod,
          note: customerNote || 'Initial deal request'
        }
      ]
    });

    // Notify farmer
    await Notification.create({
      userId: vegetable.farmerId,
      title: 'New Deal Request',
      body: `Customer sent a deal request for ${qty} ${vegetable.priceUnit} of ${vegetable.name} (Ref: ₹${refValue})`,
      type: 'DEAL_REQUEST',
      referenceId: deal._id,
      referenceType: 'Deal'
    });

    // Populate for response
    const populatedDeal = await Deal.findById(deal._id)
      .populate('farmerId', 'name phone profileImage')
      .populate('customerId', 'name phone profileImage')
      .populate('vegetableId', 'name price priceUnit images');

    res.status(201).json({
      success: true,
      message: 'Direct deal request sent to farmer. Payment is made directly between customer and farmer.',
      data: populatedDeal
    });
  } catch (error) {
    next(error);
  }
};

// Counter offer (Farmer or Customer)
exports.counterOffer = async (req, res, next) => {
  try {
    const { id } = req.params;
    const userId = req.user._id;
    const { quantity, price, preferredDate, deliveryMethod, note } = req.body;

    const deal = await Deal.findById(id);
    if (!deal) {
      return res.status(404).json({ success: false, message: 'Deal not found.' });
    }

    // Verify participant
    const isCustomer = deal.customerId.toString() === userId.toString();
    const isFarmer = deal.farmerId.toString() === userId.toString();

    if (!isCustomer && !isFarmer) {
      return res.status(403).json({ success: false, message: 'Unauthorized to negotiate this deal.' });
    }

    if ([DealStatus.COMPLETED, DealStatus.CANCELLED].includes(deal.status)) {
      return res.status(400).json({
        success: false,
        message: `Cannot counter offer a deal that is already ${deal.status.toLowerCase()}.`
      });
    }

    const newQty = quantity ? Number(quantity) : deal.agreedQuantity;
    const newPrice = price ? Number(price) : deal.agreedPrice;
    const newRefValue = Math.round(newQty * newPrice * 100) / 100;

    deal.agreedQuantity = newQty;
    deal.agreedPrice = newPrice;
    deal.dealReferenceValue = newRefValue;
    if (preferredDate) deal.preferredDate = preferredDate;
    if (deliveryMethod) deal.deliveryMethod = deliveryMethod;
    if (isFarmer && note) deal.farmerNote = note;
    if (isCustomer && note) deal.customerNote = note;

    deal.status = DealStatus.NEGOTIATING;
    deal.lastCounterBy = userId;
    deal.counterHistory.push({
      proposedBy: userId,
      quantity: newQty,
      price: newPrice,
      referenceValue: newRefValue,
      preferredDate: preferredDate || deal.preferredDate,
      deliveryMethod: deliveryMethod || deal.deliveryMethod,
      note: note || 'Counter offer'
    });

    await deal.save();

    // Notify the other party
    const targetUserId = isFarmer ? deal.customerId : deal.farmerId;
    await Notification.create({
      userId: targetUserId,
      title: 'Counter Offer Received',
      body: `${isFarmer ? 'Farmer' : 'Customer'} proposed a counter offer: ${newQty} ${deal.priceUnit} @ ₹${newPrice}/${deal.priceUnit} (₹${newRefValue})`,
      type: 'DEAL_COUNTER',
      referenceId: deal._id,
      referenceType: 'Deal'
    });

    const populated = await Deal.findById(deal._id)
      .populate('farmerId', 'name phone profileImage')
      .populate('customerId', 'name phone profileImage')
      .populate('vegetableId', 'name price priceUnit images');

    res.status(200).json({
      success: true,
      message: 'Counter offer submitted successfully.',
      data: populated
    });
  } catch (error) {
    next(error);
  }
};

// Accept Deal (Farmer or Customer accepting current terms)
exports.acceptDeal = async (req, res, next) => {
  try {
    const { id } = req.params;
    const userId = req.user._id;

    const deal = await Deal.findById(id);
    if (!deal) {
      return res.status(404).json({ success: false, message: 'Deal not found.' });
    }

    const isCustomer = deal.customerId.toString() === userId.toString();
    const isFarmer = deal.farmerId.toString() === userId.toString();

    if (!isCustomer && !isFarmer) {
      return res.status(403).json({ success: false, message: 'Unauthorized.' });
    }

    deal.status = DealStatus.ACCEPTED;
    await deal.save();

    // Notify the other party
    const targetUserId = isFarmer ? deal.customerId : deal.farmerId;
    await Notification.create({
      userId: targetUserId,
      title: 'Deal Accepted!',
      body: `Deal #${deal.dealNumber} was accepted. You can now coordinate pickup / delivery details directly.`,
      type: 'DEAL_ACCEPTED',
      referenceId: deal._id,
      referenceType: 'Deal'
    });

    const populated = await Deal.findById(deal._id)
      .populate('farmerId', 'name phone profileImage')
      .populate('customerId', 'name phone profileImage')
      .populate('vegetableId', 'name price priceUnit images');

    res.status(200).json({
      success: true,
      message: 'Deal accepted. Contact details & direct payment coordination are now active.',
      data: populated
    });
  } catch (error) {
    next(error);
  }
};

// Farmer: Mark vegetables ready for pickup/dispatch
exports.markReady = async (req, res, next) => {
  try {
    const { id } = req.params;
    const deal = await Deal.findById(id);

    if (!deal || deal.farmerId.toString() !== req.user._id.toString()) {
      return res.status(404).json({ success: false, message: 'Deal not found or unauthorized.' });
    }

    deal.status = DealStatus.READY;
    await deal.save();

    await Notification.create({
      userId: deal.customerId,
      title: 'Vegetables Ready!',
      body: `Farmer has packed your fresh vegetables for Deal #${deal.dealNumber}.`,
      type: 'DEAL_READY',
      referenceId: deal._id,
      referenceType: 'Deal'
    });

    res.status(200).json({
      success: true,
      message: 'Deal marked as ready.',
      data: deal
    });
  } catch (error) {
    next(error);
  }
};

// Deal Completion Confirmation (Customer confirms "Vegetables received", Farmer confirms "Deal completed")
exports.confirmCompletion = async (req, res, next) => {
  try {
    const { id } = req.params;
    const userId = req.user._id;

    const deal = await Deal.findById(id);
    if (!deal) {
      return res.status(404).json({ success: false, message: 'Deal not found.' });
    }

    const isCustomer = deal.customerId.toString() === userId.toString();
    const isFarmer = deal.farmerId.toString() === userId.toString();

    if (!isCustomer && !isFarmer) {
      return res.status(403).json({ success: false, message: 'Unauthorized.' });
    }

    if (isCustomer) {
      deal.customerConfirmed = true;
      deal.customerConfirmedAt = new Date();
    }
    if (isFarmer) {
      deal.farmerConfirmed = true;
      deal.farmerConfirmedAt = new Date();
    }

    // If both confirmed or either party confirms an accepted/ready deal, complete the deal
    if (deal.customerConfirmed && deal.farmerConfirmed) {
      deal.status = DealStatus.COMPLETED;
      deal.completedAt = new Date();

      // Update farmer trust metrics (completed deals count)
      await FarmerProfile.findOneAndUpdate(
        { userId: deal.farmerId },
        { $inc: { completedDealsCount: 1 } }
      );

      // Update customer profile count
      await CustomerProfile.findOneAndUpdate(
        { userId: deal.customerId },
        { $inc: { totalDealsCompleted: 1 } }
      );

      // Notify customer to leave a verified review
      await Notification.create({
        userId: deal.customerId,
        title: 'Deal Completed!',
        body: `Deal #${deal.dealNumber} is completed. Please share a verified review for the farmer.`,
        type: 'DEAL_COMPLETED',
        referenceId: deal._id,
        referenceType: 'Deal'
      });
    }

    await deal.save();

    const populated = await Deal.findById(deal._id)
      .populate('farmerId', 'name phone profileImage')
      .populate('customerId', 'name phone profileImage')
      .populate('vegetableId', 'name price priceUnit images');

    res.status(200).json({
      success: true,
      message: deal.status === DealStatus.COMPLETED
        ? 'Deal marked as completed by both parties!'
        : 'Your completion confirmation recorded. Waiting for the other party to confirm.',
      data: populated
    });
  } catch (error) {
    next(error);
  }
};

// Cancel Deal
exports.cancelDeal = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { reason } = req.body;
    const userId = req.user._id;

    const deal = await Deal.findById(id);
    if (!deal) {
      return res.status(404).json({ success: false, message: 'Deal not found.' });
    }

    const isCustomer = deal.customerId.toString() === userId.toString();
    const isFarmer = deal.farmerId.toString() === userId.toString();

    if (!isCustomer && !isFarmer && req.user.role !== UserRoles.ADMIN) {
      return res.status(403).json({ success: false, message: 'Unauthorized.' });
    }

    deal.status = DealStatus.CANCELLED;
    deal.cancelledAt = new Date();
    deal.cancelledBy = userId;
    deal.cancellationReason = reason || 'Mutually cancelled or declined';

    await deal.save();

    res.status(200).json({
      success: true,
      message: 'Deal has been cancelled.',
      data: deal
    });
  } catch (error) {
    next(error);
  }
};

// Get User's Deals (Customer or Farmer)
exports.getMyDeals = async (req, res, next) => {
  try {
    const userId = req.user._id;
    const { status, role } = req.query;

    const query = {};
    if (req.user.role === UserRoles.FARMER || role === 'farmer') {
      query.farmerId = userId;
    } else {
      query.customerId = userId;
    }

    if (status && status !== 'All') {
      query.status = status.toUpperCase();
    }

    const deals = await Deal.find(query)
      .populate('farmerId', 'name phone profileImage isVerified')
      .populate('customerId', 'name phone profileImage')
      .populate('vegetableId', 'name price priceUnit images category')
      .sort({ updatedAt: -1 });

    // Contact privacy: Strip phone/sensitive info if deal is still in REQUESTED or NEGOTIATING status
    const sanitizedDeals = deals.map((deal) => {
      const isAcceptedOrBeyond = [DealStatus.ACCEPTED, DealStatus.READY, DealStatus.COMPLETED].includes(deal.status);
      const dealObj = deal.toObject();

      if (!isAcceptedOrBeyond) {
        if (dealObj.farmerId) {
          dealObj.farmerId.phone = 'Available after deal accepted';
        }
        if (dealObj.customerId) {
          dealObj.customerId.phone = 'Available after deal accepted';
        }
      }
      return dealObj;
    });

    res.status(200).json({
      success: true,
      count: sanitizedDeals.length,
      data: sanitizedDeals
    });
  } catch (error) {
    next(error);
  }
};

// Get single deal details
exports.getDealById = async (req, res, next) => {
  try {
    const { id } = req.params;
    const userId = req.user._id;

    const deal = await Deal.findById(id)
      .populate('farmerId', 'name phone profileImage isVerified')
      .populate('customerId', 'name phone profileImage')
      .populate('vegetableId', 'name price priceUnit images category description');

    if (!deal) {
      return res.status(404).json({ success: false, message: 'Deal not found.' });
    }

    // Check authorization
    const isCustomer = deal.customerId._id.toString() === userId.toString();
    const isFarmer = deal.farmerId._id.toString() === userId.toString();
    const isAdmin = [UserRoles.ADMIN, UserRoles.SUPER_ADMIN].includes(req.user.role);

    if (!isCustomer && !isFarmer && !isAdmin) {
      return res.status(403).json({ success: false, message: 'Unauthorized access to this deal.' });
    }

    const dealObj = deal.toObject();
    const isAcceptedOrBeyond = [DealStatus.ACCEPTED, DealStatus.READY, DealStatus.COMPLETED].includes(deal.status);

    if (!isAcceptedOrBeyond && !isAdmin) {
      if (dealObj.farmerId) dealObj.farmerId.phone = 'Hidden until deal accepted';
      if (dealObj.customerId) dealObj.customerId.phone = 'Hidden until deal accepted';
    }

    res.status(200).json({
      success: true,
      data: dealObj
    });
  } catch (error) {
    next(error);
  }
};
