const express = require('express');
const router = express.Router();
const { createGroup, getAllGroups, assignMembers, deleteGroup ,assignSupervisor} = require('../../controllers/adminController/groupController');
const { protect, authorize } = require('../../middleware/authMiddleware');

router.use(protect);
router.use(authorize('Admin'));

router.post('/assign-supervisor',assignSupervisor);
router.route('/')
    .get(getAllGroups)
    .post(createGroup);
router.put('/:groupId/assign', assignMembers);
router.delete('/:groupId', deleteGroup);

module.exports = router;
