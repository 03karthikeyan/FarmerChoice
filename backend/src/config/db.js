const mongoose = require('mongoose');

const connectDB = async () => {
  try {
    const uri = process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017/farmer_choice';
    const conn = await mongoose.connect(uri, {
      serverSelectionTimeoutMS: 8000,
    });
    console.log(`[Database] MongoDB Connected Successfully: ${conn.connection.host}`);
    return true;
  } catch (error) {
    console.error(`\n======================================================`);
    console.error(`❌ [Database] MongoDB Atlas Connection Failed:`);
    console.error(`Error: ${error.message}`);
    if (error.name === 'MongooseServerSelectionError' || error.message.includes('SSL') || error.message.includes('whitelist')) {
      console.error(`\n👉 FIX: Your IP is not whitelisted on MongoDB Atlas.`);
      console.error(`1. Go to MongoDB Atlas (cloud.mongodb.com) -> Network Access`);
      console.error(`2. Click 'Add IP Address' -> Choose 'Allow Access from Anywhere' (0.0.0.0/0) or add current IP.`);
      console.error(`3. Click 'Confirm' and restart backend.`);
    }
    console.error(`======================================================\n`);
    return false;
  }
};

module.exports = connectDB;
