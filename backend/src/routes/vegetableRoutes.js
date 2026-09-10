const express = require('express');
const router = express.Router();
const vegetableController = require('../controllers/vegetableController');
const { authenticate, requireRole } = require('../middlewares/auth');
const { UserRoles } = require('../constants');

// Public listing & search
router.get('/', vegetableController.getVegetables);
router.get('/compare/:name', vegetableController.compareFarmersForVegetable);
router.get('/:id', vegetableController.getVegetableById);

// Farmer authenticated inventory routes
router.get('/farmer/my-listings', authenticate, requireRole(UserRoles.FARMER), vegetableController.getMyVegetables);
router.post('/', authenticate, requireRole(UserRoles.FARMER), vegetableController.createVegetable);
router.put('/:id', authenticate, requireRole(UserRoles.FARMER, UserRoles.ADMIN), vegetableController.updateVegetable);
router.delete('/:id', authenticate, requireRole(UserRoles.FARMER, UserRoles.ADMIN), vegetableController.deleteVegetable);
router.patch('/:id/quick-update', authenticate, requireRole(UserRoles.FARMER), vegetableController.quickUpdate);
router.post('/:id/request-featured', authenticate, requireRole(UserRoles.FARMER), vegetableController.requestFeatured);

module.exports = router;
