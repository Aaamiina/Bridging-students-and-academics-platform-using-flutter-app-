const express = require('express');
const router = express.Router();
const { 
  createGroup, 
  getAllGroups, 
  assignMembers, 
  deleteGroup, 
  assignSupervisor 
} = require('../../controllers/adminController/groupController');
const { protect, authorize } = require('../../middleware/authMiddleware');

// 1. First, apply security to ALL routes in this file
router.use(protect);
router.use(authorize('Admin'));

// 2. Static route (MUST be above the :groupId route)
router.post('/assign-supervisor', assignSupervisor);

// 3. Index routes
router.route('/')
    .get(getAllGroups)
    .post(createGroup);

// 4. Dynamic routes (MUST be at the bottom)
router.put('/:groupId/assign', assignMembers);
router.delete('/:groupId', deleteGroup);

module.exports = router;