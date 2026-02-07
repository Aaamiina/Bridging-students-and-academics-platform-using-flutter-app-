const express = require('express');
const router = express.Router();
const path = require('path');
const multer = require('multer');
const { getMyTasks, submitTask, getFeedback, getMyProfile, getMySupervisor } = require('../controllers/studentController');
const { protect, authorize } = require('../middleware/authMiddleware');

router.use(protect);
router.use(authorize('Student'));

// Multer for student submission file uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, 'uploads/'),
  filename: (req, file, cb) => cb(null, 'submission-' + Date.now() + path.extname(file.originalname || '.bin'))
});
const upload = multer({ storage });

// @route   GET api/student/profile
// @desc    Get logged-in student's name, group from database
router.get('/profile', getMyProfile);

// @route   GET api/student/my-supervisor
// @desc    Get supervisor assigned to student's group (for messaging)
router.get('/my-supervisor', getMySupervisor);

// @route   GET api/student/tasks
// @desc    View tasks assigned to the student's group
router.get('/tasks', getMyTasks);

// @route   POST api/student/submit
// @desc    Submit assignment (multipart: taskId, description, externalLink, optional file)
router.post('/submit', upload.single('file'), submitTask);

// @route   GET api/student/feedback
// @desc    View grades and supervisor comments
router.get('/feedback', getFeedback);

module.exports = router;