const express = require('express');
const router = express.Router();
const { getMyTasks, submitTask, getFeedback } = require('../controllers/studentController');
const { protect, authorize } = require('../middleware/authMiddleware');

router.use(protect);
router.use(authorize('Student'));

// @route   GET api/student/tasks
// @desc    View tasks assigned to the student's group
router.get('/tasks', getMyTasks);

// @route   POST api/student/submit
// @desc    Submit assignment work (fileUrl or externalLink)
router.post('/submit', submitTask);

// @route   GET api/student/feedback
// @desc    View grades and supervisor comments
router.get('/feedback', getFeedback);

module.exports = router;