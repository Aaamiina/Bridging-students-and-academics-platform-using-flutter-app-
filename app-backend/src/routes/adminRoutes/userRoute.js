const express = require('express');
const router = express.Router();
const {
    createUser,
    getUsers,
    updateUser,
    deleteUser,
    toggleUserStatus,
    importUsers
} = require('../../controllers/adminController/userController');
const { protect, authorize } = require('../../middleware/authMiddleware');

const multer = require('multer');
const path = require('path');

// Configure Multer Storage (disk - for profile images)
const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, 'uploads/'); // Ensure this directory exists
    },
    filename: function (req, file, cb) {
        cb(null, 'user-' + Date.now() + path.extname(file.originalname));
    }
});
const upload = multer({ storage: storage });

// Memory storage for CSV import (to read file buffer)
const uploadMemory = multer({ storage: multer.memoryStorage() });

// Apply protection to all routes below
router.use(protect);
router.use(authorize('Admin'));

// Debugging Middleware
const logBefore = (req, res, next) => { console.log('DEBUG: Middleware - Before Multer'); next(); };
const logAfter = (req, res, next) => { console.log('DEBUG: Middleware - After Multer'); next(); };

// Import users from CSV (must be before /:id)
router.post('/import', uploadMemory.single('file'), importUsers);

// Base path: /api/admin/users
router.route('/')
    .get(getUsers)    // GET all users
    .post(
        logBefore,
        (req, res, next) => {
            upload.single('profileImage')(req, res, (err) => {
                if (err) {
                    console.error("DEBUG: Multer Error:", err);
                    return res.status(500).json({ msg: 'File Upload Error', error: err.message });
                }
                next();
            });
        },
        logAfter,
        createUser
    ); // POST create user

router.route('/:id')
    .put(upload.single('profileImage'), updateUser)    // PUT update user details
    .delete(deleteUser); // DELETE user

router.patch('/:id/status', toggleUserStatus); // PATCH toggle status

module.exports = router;