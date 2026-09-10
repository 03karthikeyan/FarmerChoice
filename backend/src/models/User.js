const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const { UserRoles, UserStatus } = require('../constants');

const userSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, 'Name is required'],
      trim: true
    },
    phone: {
      type: String,
      required: [true, 'Phone number is required'],
      unique: true,
      trim: true
    },
    email: {
      type: String,
      trim: true,
      lowercase: true,
      default: ''
    },
    passwordHash: {
      type: String,
      required: [true, 'Password is required']
    },
    role: {
      type: String,
      enum: Object.values(UserRoles),
      required: [true, 'Role is required']
    },
    profileImage: {
      type: String,
      default: ''
    },
    status: {
      type: String,
      enum: Object.values(UserStatus),
      default: UserStatus.ACTIVE
    },
    isVerified: {
      type: Boolean,
      default: false
    },
    languagePreference: {
      type: String,
      enum: ['en', 'ta'],
      default: 'en'
    },
    fcmToken: {
      type: String,
      default: ''
    },
    lastLoginAt: {
      type: Date
    }
  },
  {
    timestamps: true
  }
);

userSchema.methods.comparePassword = async function (candidatePassword) {
  return bcrypt.compare(candidatePassword, this.passwordHash);
};

userSchema.statics.hashPassword = async function (password) {
  const salt = await bcrypt.genSalt(10);
  return bcrypt.hash(password, salt);
};

// Exclude passwordHash when transforming to JSON
userSchema.set('toJSON', {
  transform: function (doc, ret) {
    delete ret.passwordHash;
    return ret;
  }
});

const User = mongoose.model('User', userSchema);

module.exports = User;
