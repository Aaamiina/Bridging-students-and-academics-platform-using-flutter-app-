const express = require('express');
const router = express.Router();
const { getGlobalStats, getAllTasks, getAllSubmissions } = require('../../controllers/adminController/statsController');
const { protect, authorize } = require('../../middleware/authMiddleware');

router.use(protect);
router.use(authorize('Admin'));

router.get('/', getGlobalStats);
router.get('/tasks', getAllTasks);
router.get('/submissions', getAllSubmissions);

module.exports = router;
