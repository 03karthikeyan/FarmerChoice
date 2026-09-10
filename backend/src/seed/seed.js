require('dotenv').config();
const mongoose = require('mongoose');
const User = require('../models/User');
const FarmerProfile = require('../models/FarmerProfile');
const CustomerProfile = require('../models/CustomerProfile');
const Vegetable = require('../models/Vegetable');
const Deal = require('../models/Deal');
const Review = require('../models/Review');
const Conversation = require('../models/Conversation');
const Message = require('../models/Message');
const Notification = require('../models/Notification');
const Favorite = require('../models/Favorite');
const {
  UserRoles,
  UserStatus
} = require('../constants');

const seedDatabase = async () => {
  try {
    const mongoUri = process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017/farmer_choice';
    await mongoose.connect(mongoUri);
    console.log('[Seed] Connected to MongoDB');

    // Clean existing collections
    await Promise.all([
      User.deleteMany({}),
      FarmerProfile.deleteMany({}),
      CustomerProfile.deleteMany({}),
      Vegetable.deleteMany({}),
      Deal.deleteMany({}),
      Review.deleteMany({}),
      Conversation.deleteMany({}),
      Message.deleteMany({}),
      Notification.deleteMany({}),
      Favorite.deleteMany({})
    ]);
    console.log('[Seed] Cleared all existing demo/static data');

    const defaultPassword = 'password123';
    const passwordHash = await User.hashPassword(defaultPassword);

    // 1. Create Super Admin ONLY (All other data is added dynamically via app)
    const admin = await User.create({
      name: 'Super Admin',
      phone: '9999999999',
      email: 'admin@farmerchoice.in',
      passwordHash,
      role: UserRoles.SUPER_ADMIN,
      profileImage: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      status: UserStatus.ACTIVE,
      isVerified: true
    });

    console.log('==============================================');
    console.log('✅ Farmer Choice Database Seeded (Super Admin Only)!');
    console.log('👥 Admin Account:');
    console.log('   Email: admin@farmerchoice.in');
    console.log('   Phone: 9999999999');
    console.log('   Password: password123');
    console.log('🌱 All Farmers, Customers & Vegetables will be added via Mobile App.');
    console.log('==============================================');

    process.exit(0);
  } catch (error) {
    console.error('[Seed Error]:', error);
    process.exit(1);
  }
};

seedDatabase();
