const express = require('express');
const router = express.Router();
const customerController = require('../controllers/customerController');
const { authenticate, requireRole } = require('../middlewares/auth');
const { UserRoles } = require('../constants');

router.get('/profile', authenticate, requireRole(UserRoles.CUSTOMER), customerController.getCustomerProfile);
router.put('/profile', authenticate, requireRole(UserRoles.CUSTOMER), customerController.updateCustomerProfile);
router.delete('/account', authenticate, requireRole(UserRoles.CUSTOMER), customerController.deleteCustomerAccount);

module.exports = router;
