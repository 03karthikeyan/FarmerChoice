const express = require('express');
const router = express.Router();
const favoriteController = require('../controllers/favoriteController');
const { authenticate } = require('../middlewares/auth');

router.post('/toggle', authenticate, favoriteController.toggleFavorite);
router.get('/', authenticate, favoriteController.getMyFavorites);

module.exports = router;
