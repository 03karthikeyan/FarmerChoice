const express = require('express');
const router = express.Router();
const farmerController = require('../controllers/farmerController');
const { authenticate, requireRole } = require('../middlewares/auth');
const { UserRoles } = require('../constants');

router.get('/', farmerController.getFarmers);
router.get('/dashboard/stats', authenticate, requireRole(UserRoles.FARMER), farmerController.getDashboardStats);
router.put('/profile', authenticate, requireRole(UserRoles.FARMER), farmerController.updateFarmerProfile);
router.delete('/account', authenticate, requireRole(UserRoles.FARMER), farmerController.deleteFarmerAccount);
router.get('/:id', farmerController.getFarmerProfile);

module.exports = router;
