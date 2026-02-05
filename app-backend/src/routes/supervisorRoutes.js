const express = require('express');
const router = express.Router();
const { createTask, getSubmissionsByTask, getAllSubmissionsForSupervisor, gradeSubmission, getMyGroups, getGroupMembers,
  deleteTask, updateTask, getTasks
} = require('../controllers/supervisorController');
const { protect, authorize } = require('../middleware/authMiddleware');

router.use(protect);
router.use(authorize('Supervisor'));


// / --- Task Routes ---
// GET /api/supervisor/tasks (Fetch all tasks for the logged-in supervisor)
router.get('/tasks', getTasks);

// POST /api/supervisor/tasks (Create a new task)
router.post('/tasks', createTask);

// PUT /api/supervisor/tasks/:id (Update a specific task)
router.put('/tasks/:id', updateTask);

// DELETE /api/supervisor/tasks/:id (Delete a specific task)
router.delete('/tasks/:id', deleteTask);
// @route   GET api/supervisor/groups
// @desc    View groups created by supervisor
router.get('/groups', getMyGroups);
router.get('/groups/:groupName/members', getGroupMembers);

// @route   GET api/supervisor/submissions
// @desc    View all submissions for supervisor's tasks
router.get('/submissions', getAllSubmissionsForSupervisor);
// @route   GET api/supervisor/submissions/:taskId
// @desc    View all submissions for a specific task
router.get('/submissions/:taskId', getSubmissionsByTask);

// @route   PUT api/supervisor/grade/:id
// @desc    Provide feedback and marks for a submission
router.put('/grade/:id', gradeSubmission);

module.exports = router;