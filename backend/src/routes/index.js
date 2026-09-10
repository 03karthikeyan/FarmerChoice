const express = require('express');
const router = express.Router();

const authRoutes = require('./authRoutes');
const customerRoutes = require('./customerRoutes');
const farmerRoutes = require('./farmerRoutes');
const vegetableRoutes = require('./vegetableRoutes');
const dealRoutes = require('./dealRoutes');
const chatRoutes = require('./chatRoutes');
const reviewRoutes = require('./reviewRoutes');
const favoriteRoutes = require('./favoriteRoutes');
const notificationRoutes = require('./notificationRoutes');
const supportRoutes = require('./supportRoutes');
const reportRoutes = require('./reportRoutes');
const adminRoutes = require('./adminRoutes');
const uploadRoutes = require('./uploadRoutes');

router.use('/auth', authRoutes);
router.use('/customers', customerRoutes);
router.use('/farmers', farmerRoutes);
router.use('/vegetables', vegetableRoutes);
router.use('/deals', dealRoutes);
router.use('/chat', chatRoutes);
router.use('/reviews', reviewRoutes);
router.use('/favorites', favoriteRoutes);
router.use('/notifications', notificationRoutes);
router.use('/support', supportRoutes);
router.use('/reports', reportRoutes);
router.use('/admin', adminRoutes);
router.use('/upload', uploadRoutes);

// Health check
router.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    timestamp: new Date(),
    service: 'Farmer Choice API v1'
  });
});

module.exports = router;
