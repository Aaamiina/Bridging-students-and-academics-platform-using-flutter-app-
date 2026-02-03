const express = require('express');
const router = express.Router();
const { login, updateProfile, seedAdmin } = require('../controllers/authController');
const { protect } = require('../middleware/authMiddleware');

// @route   POST api/auth/login
// @desc    Authenticate user & get token
router.post('/login', login);

// @route   GET api/auth/seed-admin (TEMPORARY)
router.get('/seed-admin', seedAdmin);

// @route   PUT api/auth/profile
// @desc    Update user profile (Name, Email, Password)
router.put('/profile', protect, updateProfile);

module.exports = router;