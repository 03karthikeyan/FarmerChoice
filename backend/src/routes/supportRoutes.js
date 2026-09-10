const express = require('express');
const router = express.Router();
const supportController = require('../controllers/supportController');
const { authenticate } = require('../middlewares/auth');

router.post('/', authenticate, supportController.createTicket);
router.get('/my-tickets', authenticate, supportController.getMyTickets);

module.exports = router;
