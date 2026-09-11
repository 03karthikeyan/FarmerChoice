const express = require('express');
const router = express.Router();
const adminController = require('../controllers/adminController');
const { authenticate, requireRole } = require('../middlewares/auth');
const { UserRoles } = require('../constants');

// Guard all admin routes with authentication and ADMIN / SUPER_ADMIN role
router.use(authenticate);
router.use(requireRole(UserRoles.ADMIN, UserRoles.SUPER_ADMIN));

// Overview
router.get('/dashboard', adminController.getDashboardOverview);

// Farmers
router.get('/farmers', adminController.getFarmers);
router.patch('/farmers/:id/verify', adminController.verifyFarmer);
router.patch('/farmers/:id/reject', adminController.rejectFarmer);

// Customers & Users
router.get('/customers', adminController.getCustomers);
router.patch('/users/:userId/status', adminController.toggleUserStatus);

// Vegetables
router.get('/vegetables', adminController.getVegetables);
router.patch('/vegetables/:id/featured', adminController.moderateFeatured);

// Deals & Reviews
router.get('/deals', adminController.getDeals);
router.get('/reviews', adminController.getReviews);
router.patch('/reviews/:id/status', adminController.moderateReview);

// Reports & Support
router.get('/reports', adminController.getReports);
router.patch('/reports/:id/resolve', adminController.resolveReport);
router.get('/support', adminController.getSupportTickets);
router.patch('/support/:id', adminController.updateSupportTicket);

// Admin / Super Admin Staff Management
router.get('/admins', adminController.getAdmins);
router.post('/admins', adminController.createAdmin);
router.patch('/admins/:id', adminController.updateAdmin);
router.delete('/admins/:id', adminController.deleteAdmin);

// Audit
router.get('/audit-logs', adminController.getAuditLogs);

module.exports = router;

