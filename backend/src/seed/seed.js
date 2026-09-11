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

    const defaultPassword = 'password123';
    const passwordHash = await User.hashPassword(defaultPassword);

    // 1. Create or Update Super Admin in MongoDB
    const adminData = {
      name: 'Super Admin',
      phone: '9999999999',
      email: 'admin@farmerchoice.in',
      passwordHash,
      role: UserRoles.SUPER_ADMIN,
      profileImage: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      status: UserStatus.ACTIVE,
      isVerified: true
    };

    const admin = await User.findOneAndUpdate(
      { $or: [{ role: UserRoles.SUPER_ADMIN }, { phone: '9999999999' }, { email: 'admin@farmerchoice.in' }] },
      { $set: adminData },
      { upsert: true, new: true, setDefaultsOnInsert: true }
    );

    console.log('==============================================');
    console.log('✅ Farmer Choice Super Admin Updated / Created in MongoDB!');
    console.log('👥 Admin Account Details:');
    console.log(`   ID: ${admin._id}`);
    console.log('   Name: ' + admin.name);
    console.log('   Email: ' + admin.email);
    console.log('   Phone: ' + admin.phone);
    console.log('   Password: ' + defaultPassword);
    console.log('   Role: ' + admin.role);
    console.log('   Status: ' + admin.status);
    console.log('   Verified: ' + admin.isVerified);
    console.log('==============================================');

    process.exit(0);
  } catch (error) {
    console.error('[Seed Error]:', error);
    process.exit(1);
  }
};

seedDatabase();
