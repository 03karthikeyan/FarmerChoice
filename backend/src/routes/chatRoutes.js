const express = require('express');
const router = express.Router();
const chatController = require('../controllers/chatController');
const { authenticate } = require('../middlewares/auth');

router.get('/conversations', authenticate, chatController.getConversations);
router.post('/conversations', authenticate, chatController.createOrGetConversation);
router.get('/conversations/:conversationId/messages', authenticate, chatController.getMessages);
router.post('/conversations/:conversationId/messages', authenticate, chatController.sendMessage);

module.exports = router;
