const express = require('express');
const router = express.Router();
const dealController = require('../controllers/dealController');
const { authenticate, requireRole } = require('../middlewares/auth');
const { UserRoles } = require('../constants');

router.get('/my-deals', authenticate, dealController.getMyDeals);
router.get('/:id', authenticate, dealController.getDealById);

// Customer creates deal request
router.post('/request', authenticate, requireRole(UserRoles.CUSTOMER), dealController.createDealRequest);

// Negotiation & Actions
router.post('/:id/counter', authenticate, dealController.counterOffer);
router.post('/:id/accept', authenticate, dealController.acceptDeal);
router.post('/:id/ready', authenticate, requireRole(UserRoles.FARMER), dealController.markReady);
router.post('/:id/complete', authenticate, dealController.confirmCompletion);
router.post('/:id/cancel', authenticate, dealController.cancelDeal);

module.exports = router;
