const express = require('express');
const router = express.Router();
const { 
    createUser, 
    getUsers, 
    updateUser, 
    deleteUser, 
    toggleUserStatus 
} = require('../../controllers/adminController/userController');
const { protect, authorize } = require('../../middleware/authMiddleware');

// Apply protection to all routes below
router.use(protect);
router.use(authorize('Admin'));

// Base path: /api/admin/users
router.route('/')
    .get(getUsers)    // GET all users
    .post(createUser); // POST create user

router.route('/:id')
    .put(updateUser)    // PUT update user details
    .delete(deleteUser); // DELETE user

router.patch('/:id/status', toggleUserStatus); // PATCH toggle status

module.exports = router;