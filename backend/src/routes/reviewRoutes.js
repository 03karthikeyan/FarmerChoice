const express = require('express');
const router = express.Router();
const reviewController = require('../controllers/reviewController');
const { authenticate, requireRole } = require('../middlewares/auth');
const { UserRoles } = require('../constants');

// Customer submits verified review
router.post('/', authenticate, requireRole(UserRoles.CUSTOMER), reviewController.createReview);
router.get('/farmer/:farmerId', reviewController.getFarmerReviews);
router.post('/:id/reply', authenticate, requireRole(UserRoles.FARMER), reviewController.replyToReview);

module.exports = router;
