const Task = require('../models/task');
const Submission = require('../models/Submission');
const Group = require('../models/group');
const User = require('../models/User');
const mongoose = require('mongoose');

// Get current student profile from database (name, group, etc.)
exports.getMyProfile = async (req, res) => {
  try {
    const student = await User.findById(req.user.id)
      .select('name email group studentId')
      .lean();
    if (!student) return res.status(404).json({ msg: 'User not found' });
    res.json({
      name: (student.name || '').trim(),
      email: (student.email || '').trim(),
      group: student.group ? String(student.group).trim() : null,
      studentId: student.studentId ? String(student.studentId).trim() : null,
    });
  } catch (err) {
    res.status(500).send('Server Error');
  }
};

// Normalize group name for matching (trim, collapse spaces: "Group A" and "GroupA" match)
function normalizeGroupName(str) {
  if (!str || typeof str !== 'string') return '';
  return str.trim().replace(/\s+/g, '').toLowerCase();
}

// View Assigned Tasks – use student's group from DB (admin assigns students to groups)
exports.getMyTasks = async (req, res) => {
  try {
    const student = await User.findById(req.user.id).select('group');
    const groupValue = student?.group;
    if (!groupValue) return res.json([]);

    const trimmed = String(groupValue).trim();
    let group = await Group.findOne({ name: trimmed });
    if (!group && mongoose.Types.ObjectId.isValid(trimmed)) {
      group = await Group.findById(trimmed);
    }
    // Match "GroupA" to "Group A" (and similar): find by normalized name
    if (!group) {
      const normalized = normalizeGroupName(groupValue);
      const allGroups = await Group.find().lean();
      group = allGroups.find(g => normalizeGroupName(g.name) === normalized);
      if (group) group = await Group.findById(group._id);
    }
    if (!group) return res.json([]);

    const tasks = await Task.find({ groupId: group._id }).sort({ deadline: 1 }).lean();
    const taskIds = tasks.map(t => t._id);
    const submissions = await Submission.find({
      studentId: req.user.id,
      taskId: { $in: taskIds },
    }).lean();
    const submittedTaskIds = new Set(submissions.map(s => String(s.taskId)));
    const tasksWithStatus = tasks.map(t => ({
      ...t,
      submitted: submittedTaskIds.has(String(t._id)),
    }));
    res.json(tasksWithStatus);
  } catch (err) {
    res.status(500).send('Server Error');
  }
};

// Submit Work (accepts multipart: taskId, description, externalLink, and optional file)
// One submission per student per task: if already submitted, update it instead of creating a new one
exports.submitTask = async (req, res) => {
  try {
    const taskId = req.body.taskId;
    const description = req.body.description;
    const externalLink = req.body.externalLink;
    let fileUrl = req.body.fileUrl;
    if (req.file && req.file.path) {
      fileUrl = req.file.path.replace(/\\/g, '/');
    }
    const existing = await Submission.findOne({ taskId, studentId: req.user.id });
    if (existing) {
      existing.description = description || existing.description;
      existing.externalLink = externalLink ?? existing.externalLink;
      if (fileUrl !== undefined) existing.fileUrl = fileUrl || undefined;
      existing.status = 'Submitted';
      await existing.save();
      return res.json({ msg: 'Submission updated successfully' });
    }
    const submission = new Submission({
      taskId,
      studentId: req.user.id,
      fileUrl: fileUrl || undefined,
      description: description || undefined,
      externalLink: externalLink || undefined,
      status: 'Submitted'
    });
    await submission.save();
    res.json({ msg: 'Assignment submitted successfully' });
  } catch (err) {
    res.status(500).send('Server Error');
  }
};

// View Results (Grades/Feedback)
exports.getFeedback = async (req, res) => {
  try {
    const submissions = await Submission.find({ studentId: req.user.id })
      .populate('taskId', 'title');
    res.json(submissions);
  } catch (err) {
    res.status(500).send('Server Error');
  }
};