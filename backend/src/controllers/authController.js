const jwt = require('jsonwebtoken');
const User = require('../models/User');
const FarmerProfile = require('../models/FarmerProfile');
const CustomerProfile = require('../models/CustomerProfile');
const { UserRoles, FarmerVerificationStatus, UserStatus } = require('../constants');

const generateTokens = (user) => {
  const payload = {
    id: user._id,
    role: user.role,
    name: user.name,
    phone: user.phone
  };

  const accessToken = jwt.sign(
    payload,
    process.env.JWT_SECRET || 'farmer_choice_super_secret_jwt_key_2026_secure',
    { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
  );

  const refreshToken = jwt.sign(
    { id: user._id },
    process.env.JWT_REFRESH_SECRET || 'farmer_choice_super_refresh_jwt_key_2026_secure',
    { expiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '30d' }
  );

  return { accessToken, refreshToken };
};

// Register
exports.register = async (req, res, next) => {
  try {
    const {
      name,
      phone,
      email,
      password,
      role,
      profileImage,
      // Customer specific fields
      villageOrTown,
      district,
      state = 'Tamil Nadu',
      defaultDeliveryAddress,
      // Farmer specific fields
      farmName,
      village,
      taluk,
      farmAddress,
      farmPhotos,
      aboutMe,
      latitude,
      longitude
    } = req.body;

    if (!name || !phone || !password || !role) {
      return res.status(400).json({
        success: false,
        message: 'Name, phone, password, and role are required.'
      });
    }

    if (![UserRoles.CUSTOMER, UserRoles.FARMER].includes(role)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid role selection. Must be CUSTOMER or FARMER.'
      });
    }

    // Check if phone already registered
    const existingUser = await User.findOne({ phone: phone.trim() });
    if (existingUser) {
      return res.status(400).json({
        success: false,
        message: 'Mobile number already registered. Please login instead.'
      });
    }

    // Hash password
    const passwordHash = await User.hashPassword(password);

    // Create user
    const newUser = await User.create({
      name: name.trim(),
      phone: phone.trim(),
      email: email ? email.trim() : '',
      passwordHash,
      role,
      profileImage: profileImage || '',
      status: UserStatus.ACTIVE,
      isVerified: role === UserRoles.CUSTOMER ? true : false,
      lastLoginAt: new Date()
    });

    let profileData = null;

    // Create role-specific profile
    if (role === UserRoles.CUSTOMER) {
      profileData = await CustomerProfile.create({
        userId: newUser._id,
        villageOrTown: villageOrTown || district || 'Town',
        district: district || 'Thanjavur',
        state: state || 'Tamil Nadu',
        defaultDeliveryAddress: defaultDeliveryAddress || `${villageOrTown || ''}, ${district || ''}`,
        location: {
          type: 'Point',
          coordinates: [longitude ? Number(longitude) : 79.1378, latitude ? Number(latitude) : 10.7870]
        }
      });
    } else if (role === UserRoles.FARMER) {
      profileData = await FarmerProfile.create({
        userId: newUser._id,
        farmName: farmName || `${name.trim()}'s Organic Farm`,
        village: village || villageOrTown || 'Farm Village',
        taluk: taluk || '',
        district: district || 'Thanjavur',
        state: state || 'Tamil Nadu',
        farmAddress: farmAddress || `${village || 'Village'}, ${district || 'Thanjavur'}`,
        farmPhotos: farmPhotos || [],
        aboutMe: aboutMe || 'Experienced farmer growing high quality natural vegetables directly for customers.',
        verificationStatus: FarmerVerificationStatus.PENDING,
        location: {
          type: 'Point',
          coordinates: [longitude ? Number(longitude) : 79.1378, latitude ? Number(latitude) : 10.7870]
        }
      });
    }

    const { accessToken, refreshToken } = generateTokens(newUser);

    res.status(201).json({
      success: true,
      message: `${role === UserRoles.FARMER ? 'Farmer' : 'Customer'} account created successfully.`,
      data: {
        user: newUser,
        profile: profileData,
        accessToken,
        refreshToken
      }
    });
  } catch (error) {
    next(error);
  }
};

// Login
exports.login = async (req, res, next) => {
  try {
    const { identifier, phone, email, password } = req.body;
    const loginIdentifier = (identifier || phone || email || '').trim();

    if (!loginIdentifier || !password) {
      return res.status(400).json({
        success: false,
        message: 'Please provide mobile number/email and password.'
      });
    }

    // Find user by phone or email
    const user = await User.findOne({
      $or: [{ phone: loginIdentifier }, { email: loginIdentifier.toLowerCase() }]
    });

    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Invalid mobile number/email or password.'
      });
    }

    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: 'Invalid mobile number/email or password.'
      });
    }

    if (user.status === UserStatus.SUSPENDED) {
      return res.status(403).json({
        success: false,
        message: 'Your account has been suspended by administration. Please contact support.'
      });
    }

    // Update last login
    user.lastLoginAt = new Date();
    await user.save();

    // Fetch profile
    let profile = null;
    if (user.role === UserRoles.FARMER) {
      profile = await FarmerProfile.findOne({ userId: user._id });
    } else if (user.role === UserRoles.CUSTOMER) {
      profile = await CustomerProfile.findOne({ userId: user._id });
    }

    const { accessToken, refreshToken } = generateTokens(user);

    res.status(200).json({
      success: true,
      message: 'Login successful.',
      data: {
        user,
        profile,
        accessToken,
        refreshToken
      }
    });
  } catch (error) {
    next(error);
  }
};

// Refresh Token
exports.refreshToken = async (req, res, next) => {
  try {
    const { refreshToken } = req.body;
    if (!refreshToken) {
      return res.status(400).json({ success: false, message: 'Refresh token is required.' });
    }

    const decoded = jwt.verify(
      refreshToken,
      process.env.JWT_REFRESH_SECRET || 'farmer_choice_super_refresh_jwt_key_2026_secure'
    );

    const user = await User.findById(decoded.id);
    if (!user || user.status === UserStatus.SUSPENDED) {
      return res.status(401).json({ success: false, message: 'Invalid refresh token or inactive account.' });
    }

    const tokens = generateTokens(user);

    res.status(200).json({
      success: true,
      data: tokens
    });
  } catch (error) {
    return res.status(401).json({ success: false, message: 'Invalid or expired refresh token.' });
  }
};

// Get current user Profile
exports.getMe = async (req, res, next) => {
  try {
    const user = await User.findById(req.user._id);
    let profile = null;

    if (user.role === UserRoles.FARMER) {
      profile = await FarmerProfile.findOne({ userId: user._id });
    } else if (user.role === UserRoles.CUSTOMER) {
      profile = await CustomerProfile.findOne({ userId: user._id });
    }

    res.status(200).json({
      success: true,
      data: {
        user,
        profile
      }
    });
  } catch (error) {
    next(error);
  }
};

// Update Profile
exports.updateProfile = async (req, res, next) => {
  try {
    const { name, email, profileImage, languagePreference, fcmToken } = req.body;
    const user = await User.findById(req.user._id);

    if (name) user.name = name.trim();
    if (email !== undefined) user.email = email.trim();
    if (profileImage !== undefined) user.profileImage = profileImage;
    if (languagePreference) user.languagePreference = languagePreference;
    if (fcmToken) user.fcmToken = fcmToken;

    await user.save();

    let profile = null;
    if (user.role === UserRoles.FARMER) {
      const { farmName, village, taluk, district, state, farmAddress, aboutMe, farmPhotos, allowFarmVisit } = req.body;
      profile = await FarmerProfile.findOne({ userId: user._id });
      if (profile) {
        if (farmName) profile.farmName = farmName;
        if (village) profile.village = village;
        if (taluk) profile.taluk = taluk;
        if (district) profile.district = district;
        if (state) profile.state = state;
        if (farmAddress) profile.farmAddress = farmAddress;
        if (aboutMe) profile.aboutMe = aboutMe;
        if (farmPhotos) profile.farmPhotos = farmPhotos;
        if (allowFarmVisit !== undefined) profile.allowFarmVisit = allowFarmVisit;
        await profile.save();
      }
    } else if (user.role === UserRoles.CUSTOMER) {
      const { villageOrTown, district, state, defaultDeliveryAddress } = req.body;
      profile = await CustomerProfile.findOne({ userId: user._id });
      if (profile) {
        if (villageOrTown) profile.villageOrTown = villageOrTown;
        if (district) profile.district = district;
        if (state) profile.state = state;
        if (defaultDeliveryAddress) profile.defaultDeliveryAddress = defaultDeliveryAddress;
        await profile.save();
      }
    }

    res.status(200).json({
      success: true,
      message: 'Profile updated successfully.',
      data: { user, profile }
    });
  } catch (error) {
    next(error);
  }
};
