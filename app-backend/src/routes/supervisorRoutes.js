const express = require('express');
const router = express.Router();
const { createTask, getSubmissionsByTask, gradeSubmission, getMyGroups } = require('../controllers/supervisorController');
const { protect, authorize } = require('../middleware/authMiddleware');

router.use(protect);
router.use(authorize('Supervisor'));

// @route   POST api/supervisor/tasks
// @desc    Create and distribute assignments to groups
router.post('/tasks', createTask);

// @route   GET api/supervisor/groups
// @desc    View groups created by supervisor
router.get('/groups', getMyGroups);

// @route   GET api/supervisor/submissions/:taskId
// @desc    View all submissions for a specific task
router.get('/submissions/:taskId', getSubmissionsByTask);

// @route   PUT api/supervisor/grade/:id
// @desc    Provide feedback and marks for a submission
router.put('/grade/:id', gradeSubmission);

module.exports = router;