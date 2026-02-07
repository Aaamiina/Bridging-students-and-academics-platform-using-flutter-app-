const express = require('express');
const router = express.Router();
const { getMessages, sendMessage, getConversations } = require('../controllers/messageController');
const { protect } = require('../middleware/authMiddleware');

router.use(protect);

// GET /api/messages?with=userId - messages between me and userId
router.get('/', getMessages);
// GET /api/messages/conversations - list of people I chatted with
router.get('/conversations', getConversations);
// POST /api/messages - body: { receiverId, content }
router.post('/', sendMessage);

module.exports = router;
