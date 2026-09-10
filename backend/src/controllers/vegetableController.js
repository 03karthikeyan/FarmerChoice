const Vegetable = require('../models/Vegetable');
const FarmerProfile = require('../models/FarmerProfile');
const User = require('../models/User');
const { FeaturedStatus, AvailabilityStatus } = require('../constants');

// Search & List Vegetables
exports.getVegetables = async (req, res, next) => {
  try {
    const {
      search,
      category,
      minPrice,
      maxPrice,
      district,
      availabilityStatus,
      isOrganic,
      isFeatured,
      sortBy = 'newest',
      page = 1,
      limit = 20
    } = req.query;

    const query = { status: 'ACTIVE' };

    if (search) {
      query.$or = [
        { name: { $regex: search, $options: 'i' } },
        { tamilName: { $regex: search, $options: 'i' } },
        { description: { $regex: search, $options: 'i' } }
      ];
    }

    if (category && category !== 'All') {
      query.category = category;
    }

    if (availabilityStatus) {
      query.availabilityStatus = availabilityStatus;
    }

    if (isOrganic !== undefined) {
      query.isOrganic = isOrganic === 'true';
    }

    if (isFeatured === 'true') {
      query.featuredStatus = FeaturedStatus.APPROVED;
    }

    if (minPrice || maxPrice) {
      query.price = {};
      if (minPrice) query.price.$gte = Number(minPrice);
      if (maxPrice) query.price.$lte = Number(maxPrice);
    }

    // Sort strategy
    let sortOptions = { createdAt: -1 };
    if (sortBy === 'lowest_price') {
      sortOptions = { price: 1 };
    } else if (sortBy === 'highest_price') {
      sortOptions = { price: -1 };
    } else if (sortBy === 'available_now') {
      sortOptions = { availabilityStatus: 1, createdAt: -1 };
    } else if (sortBy === 'popular') {
      sortOptions = { viewCount: -1 };
    }

    const skip = (Number(page) - 1) * Number(limit);

    const [vegetables, total] = await Promise.all([
      Vegetable.find(query)
        .populate({
          path: 'farmerId',
          select: 'name phone profileImage isVerified'
        })
        .populate({
          path: 'farmerProfileId',
          select: 'village district state rating totalReviews completedDealsCount verificationStatus isOrganicCertified badges'
        })
        .sort(sortOptions)
        .skip(skip)
        .limit(Number(limit)),
      Vegetable.countDocuments(query)
    ]);

    // Optional district filter based on farmer profile
    let filteredVegetables = vegetables;
    if (district) {
      filteredVegetables = vegetables.filter(
        (v) => v.farmerProfileId && v.farmerProfileId.district.toLowerCase() === district.toLowerCase()
      );
    }

    res.status(200).json({
      success: true,
      total: district ? filteredVegetables.length : total,
      page: Number(page),
      totalPages: Math.ceil((district ? filteredVegetables.length : total) / Number(limit)),
      data: filteredVegetables
    });
  } catch (error) {
    next(error);
  }
};

// Get single vegetable details
exports.getVegetableById = async (req, res, next) => {
  try {
    const { id } = req.params;

    const vegetable = await Vegetable.findById(id)
      .populate({
        path: 'farmerId',
        select: 'name phone profileImage isVerified createdAt'
      })
      .populate({
        path: 'farmerProfileId',
        select: 'farmName village taluk district state farmAddress aboutMe rating totalReviews completedDealsCount verificationStatus badges allowFarmVisit farmPhotos'
      });

    if (!vegetable) {
      return res.status(404).json({ success: false, message: 'Vegetable not found.' });
    }

    // Increment view count asynchronously
    vegetable.viewCount += 1;
    await vegetable.save();

    // Find other farmers selling the same vegetable (Customer Comparison Feature)
    const otherFarmerListings = await Vegetable.find({
      name: { $regex: new RegExp(`^${vegetable.name}$`, 'i') },
      _id: { $ne: vegetable._id },
      status: 'ACTIVE'
    })
      .populate({
        path: 'farmerId',
        select: 'name phone profileImage isVerified'
      })
      .populate({
        path: 'farmerProfileId',
        select: 'village district rating totalReviews completedDealsCount verificationStatus'
      })
      .limit(6);

    res.status(200).json({
      success: true,
      data: {
        vegetable,
        otherFarmers: otherFarmerListings
      }
    });
  } catch (error) {
    next(error);
  }
};

// Compare farmers selling a particular vegetable name
exports.compareFarmersForVegetable = async (req, res, next) => {
  try {
    const { name } = req.params;
    const { sortBy = 'price' } = req.query;

    let sort = { price: 1 };
    if (sortBy === 'rating') sort = { 'farmerProfileId.rating': -1 };
    if (sortBy === 'completedDeals') sort = { 'farmerProfileId.completedDealsCount': -1 };

    const listings = await Vegetable.find({
      name: { $regex: new RegExp(`^${name}$`, 'i') },
      status: 'ACTIVE'
    })
      .populate({
        path: 'farmerId',
        select: 'name phone profileImage isVerified'
      })
      .populate({
        path: 'farmerProfileId',
        select: 'farmName village district rating totalReviews completedDealsCount verificationStatus badges'
      })
      .sort(sort);

    res.status(200).json({
      success: true,
      count: listings.length,
      data: listings
    });
  } catch (error) {
    next(error);
  }
};

// Farmer: Create new vegetable listing
exports.createVegetable = async (req, res, next) => {
  try {
    const farmerId = req.user._id;
    const farmerProfile = await FarmerProfile.findOne({ userId: farmerId });

    if (!farmerProfile) {
      return res.status(400).json({
        success: false,
        message: 'Farmer profile not found. Please complete your farm profile first.'
      });
    }

    const {
      name,
      tamilName,
      category,
      images,
      description,
      price,
      priceUnit = 'kg',
      availableQuantity,
      minOrderQuantity = 1,
      availabilityStatus = AvailabilityStatus.AVAILABLE_NOW,
      availableFrom,
      availableUntil,
      harvestDate,
      isOrganic = true
    } = req.body;

    if (!name || price === undefined || availableQuantity === undefined) {
      return res.status(400).json({
        success: false,
        message: 'Vegetable name, price, and available quantity are required.'
      });
    }

    const vegetable = await Vegetable.create({
      farmerId,
      farmerProfileId: farmerProfile._id,
      name: name.trim(),
      tamilName: tamilName ? tamilName.trim() : '',
      category: category || 'Vegetable',
      images: images && images.length ? images : ['/assets/images/vegetables/default.png'],
      description: description || '',
      price: Number(price),
      priceUnit,
      availableQuantity: Number(availableQuantity),
      minOrderQuantity: Number(minOrderQuantity),
      availabilityStatus,
      availableFrom: availableFrom || new Date(),
      availableUntil: availableUntil || null,
      harvestDate: harvestDate || null,
      isOrganic
    });

    res.status(201).json({
      success: true,
      message: 'Vegetable listing created successfully.',
      data: vegetable
    });
  } catch (error) {
    next(error);
  }
};

// Farmer: Update vegetable
exports.updateVegetable = async (req, res, next) => {
  try {
    const { id } = req.params;
    const vegetable = await Vegetable.findById(id);

    if (!vegetable) {
      return res.status(404).json({ success: false, message: 'Vegetable not found.' });
    }

    // IDOR protection: only owning farmer or admin can update
    if (vegetable.farmerId.toString() !== req.user._id.toString() && req.user.role !== 'ADMIN') {
      return res.status(403).json({
        success: false,
        message: 'Unauthorized: You can only edit your own vegetable listings.'
      });
    }

    const updatableFields = [
      'name',
      'tamilName',
      'category',
      'images',
      'description',
      'price',
      'priceUnit',
      'availableQuantity',
      'minOrderQuantity',
      'availabilityStatus',
      'availableFrom',
      'availableUntil',
      'harvestDate',
      'isOrganic',
      'status'
    ];

    updatableFields.forEach((field) => {
      if (req.body[field] !== undefined) {
        vegetable[field] = req.body[field];
      }
    });

    await vegetable.save();

    res.status(200).json({
      success: true,
      message: 'Vegetable updated successfully.',
      data: vegetable
    });
  } catch (error) {
    next(error);
  }
};

// Farmer: Quick price & stock update
exports.quickUpdate = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { price, availableQuantity, availabilityStatus } = req.body;

    const vegetable = await Vegetable.findById(id);
    if (!vegetable) {
      return res.status(404).json({ success: false, message: 'Vegetable not found.' });
    }

    if (vegetable.farmerId.toString() !== req.user._id.toString()) {
      return res.status(403).json({ success: false, message: 'Unauthorized action.' });
    }

    if (price !== undefined) vegetable.price = Number(price);
    if (availableQuantity !== undefined) vegetable.availableQuantity = Number(availableQuantity);
    if (availabilityStatus) vegetable.availabilityStatus = availabilityStatus;

    if (vegetable.availableQuantity === 0 && !availabilityStatus) {
      vegetable.availabilityStatus = AvailabilityStatus.OUT_OF_STOCK;
    }

    await vegetable.save();

    res.status(200).json({
      success: true,
      message: 'Price/Stock updated immediately.',
      data: vegetable
    });
  } catch (error) {
    next(error);
  }
};

// Farmer: Request featured status
exports.requestFeatured = async (req, res, next) => {
  try {
    const { id } = req.params;
    const vegetable = await Vegetable.findById(id);

    if (!vegetable || vegetable.farmerId.toString() !== req.user._id.toString()) {
      return res.status(404).json({ success: false, message: 'Vegetable not found or unauthorized.' });
    }

    vegetable.featuredStatus = FeaturedStatus.REQUESTED;
    vegetable.featuredRequestedAt = new Date();
    await vegetable.save();

    res.status(200).json({
      success: true,
      message: 'Featured vegetable request submitted for Admin review.',
      data: vegetable
    });
  } catch (error) {
    next(error);
  }
};

// Farmer: Get all listings of logged-in farmer
exports.getMyVegetables = async (req, res, next) => {
  try {
    const { status } = req.query;
    const query = { farmerId: req.user._id };

    if (status && status !== 'All') {
      if (status === 'Available') query.availabilityStatus = AvailabilityStatus.AVAILABLE_NOW;
      else if (status === 'Limited Stock') query.availabilityStatus = AvailabilityStatus.LIMITED_STOCK;
      else if (status === 'Out of Stock') query.availabilityStatus = AvailabilityStatus.OUT_OF_STOCK;
    }

    const vegetables = await Vegetable.find(query).sort({ updatedAt: -1 });

    res.status(200).json({
      success: true,
      count: vegetables.length,
      data: vegetables
    });
  } catch (error) {
    next(error);
  }
};

// Farmer / Admin: Delete vegetable listing
exports.deleteVegetable = async (req, res, next) => {
  try {
    const { id } = req.params;
    const vegetable = await Vegetable.findById(id);

    if (!vegetable) {
      return res.status(404).json({ success: false, message: 'Vegetable not found.' });
    }

    // IDOR protection: only owning farmer or admin can delete
    if (vegetable.farmerId.toString() !== req.user._id.toString() && req.user.role !== 'SUPER_ADMIN' && req.user.role !== 'ADMIN') {
      return res.status(403).json({
        success: false,
        message: 'Unauthorized: You can only delete your own vegetable listings.'
      });
    }

    await Vegetable.findByIdAndDelete(id);

    res.status(200).json({
      success: true,
      message: 'Vegetable listing deleted successfully.'
    });
  } catch (error) {
    next(error);
  }
};
