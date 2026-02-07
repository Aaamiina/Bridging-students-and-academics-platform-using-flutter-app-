const Message = require('../models/Message');
const User = require('../models/User');
const Group = require('../models/group');
const mongoose = require('mongoose');

// GET /api/messages?with=userId - get messages between current user and userId
exports.getMessages = async (req, res) => {
  try {
    const withUserId = req.query.with;
    if (!withUserId || !mongoose.Types.ObjectId.isValid(withUserId)) {
      return res.status(400).json({ msg: 'Valid user id (with) is required' });
    }
    const myId = req.user.id;
    const messages = await Message.find({
      $or: [
        { senderId: myId, receiverId: withUserId },
        { senderId: withUserId, receiverId: myId },
      ],
    })
      .sort({ createdAt: 1 })
      .populate('senderId', 'name')
      .populate('receiverId', 'name')
      .lean();
    res.json(messages);
  } catch (err) {
    console.error('getMessages:', err);
    res.status(500).json({ msg: 'Server Error' });
  }
};

// POST /api/messages - send a message (body: receiverId, content)
exports.sendMessage = async (req, res) => {
  try {
    const { receiverId, content } = req.body;
    if (!receiverId || !content || typeof content !== 'string' || !content.trim()) {
      return res.status(400).json({ msg: 'receiverId and content are required' });
    }
    if (!mongoose.Types.ObjectId.isValid(receiverId)) {
      return res.status(400).json({ msg: 'Invalid receiver id' });
    }
    const receiver = await User.findById(receiverId).select('_id');
    if (!receiver) return res.status(404).json({ msg: 'Receiver not found' });

    const msg = new Message({
      senderId: req.user.id,
      receiverId: receiverId,
      content: content.trim(),
    });
    await msg.save();
    const populated = await Message.findById(msg._id)
      .populate('senderId', 'name')
      .populate('receiverId', 'name')
      .lean();
    res.status(201).json(populated);
  } catch (err) {
    console.error('sendMessage:', err);
    res.status(500).json({ msg: 'Server Error' });
  }
};

// GET /api/messages/conversations - list users I have chatted with (for inbox)
exports.getConversations = async (req, res) => {
  try {
    const myId = req.user.id;
    const messages = await Message.find({
      $or: [{ senderId: myId }, { receiverId: myId }],
    })
      .sort({ createdAt: -1 })
      .populate('senderId', 'name')
      .populate('receiverId', 'name')
      .lean();

    const seen = new Set();
    const list = [];
    for (const m of messages) {
      const otherId = String(m.senderId._id) === myId ? m.receiverId : m.senderId;
      const otherIdStr = String(otherId._id);
      if (seen.has(otherIdStr)) continue;
      seen.add(otherIdStr);
      list.push({
        userId: String(otherId._id),
        name: otherId.name || 'Unknown',
        lastMessage: m.content,
        lastAt: m.createdAt,
      });
    }
    res.json(list);
  } catch (err) {
    console.error('getConversations:', err);
    res.status(500).json({ msg: 'Server Error' });
  }
};
