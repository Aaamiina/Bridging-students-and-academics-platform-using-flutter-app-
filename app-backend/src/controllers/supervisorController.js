const mongoose = require('mongoose');
const Task = require('../models/task');
const Submission = require('../models/Submission');
const Group = require('../models/group');
const User = require('../models/User');   

// Create Task & Distribute
exports.getTasks = async (req, res) => {
    try {
        // Populating groupId to get the group name if needed in the UI
        const tasks = await Task.find({ createdBy: req.user.id })
            .populate('groupId', 'name')
            .sort({ createdAt: -1 });
        res.json(tasks);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};

// Create Task
// controllers/supervisorController.js

exports.createTask = async (req, res) => {
    try {
        // Destructure 'group_id' as sent by the Flutter Repository
        const { title, description, deadline, group_id } = req.body;

        const task = new Task({
            title,
            description,
            deadline: new Date(deadline),
            groupId: group_id, // Map the snake_case variable to the camelCase schema field
            createdBy: req.user.id
        });

        await task.save();
        res.status(201).json(task);
    } catch (err) {
        console.error("DEBUG: Create Task Error:", err);
        // It's helpful to send the error message back to Flutter during debugging
        res.status(500).json({ message: 'Server Error', error: err.message });
    }
};
// Update Task
exports.updateTask = async (req, res) => {
    try {
        const { title, description, deadline, status } = req.body;
        
        let task = await Task.findById(req.params.id);
        if (!task) return res.status(404).json({ msg: 'Task not found' });

        // Ensure user owns the task
        if (task.createdBy.toString() !== req.user.id) {
            return res.status(401).json({ msg: 'User not authorized' });
        }

        task = await Task.findByIdAndUpdate(
            req.params.id,
            { $set: { title, description, deadline, status } },
            { new: true }
        );

        res.json(task);
    } catch (err) {
        res.status(500).send('Server Error');
    }
};

// Delete Task
exports.deleteTask = async (req, res) => {
    try {
        const taskId = (req.params.id || '').trim();
        if (!taskId) return res.status(400).json({ msg: 'Task ID is required' });

        if (!mongoose.Types.ObjectId.isValid(taskId)) {
            return res.status(400).json({ msg: 'Invalid task ID format' });
        }

        const task = await Task.findById(taskId);
        if (!task) {
            console.log('DELETE task 404: id=', taskId);
            return res.status(404).json({ msg: 'Task not found' });
        }

        if (task.createdBy && task.createdBy.toString() !== req.user.id) {
            return res.status(403).json({ msg: 'Not authorized to delete this task' });
        }

        await Task.findByIdAndDelete(taskId);
        res.json({ msg: 'Task removed' });
    } catch (err) {
        console.error('deleteTask error:', err);
        res.status(500).json({ msg: 'Server Error' });
    }
};

// Review Submissions for a specific task
exports.getSubmissionsByTask = async (req, res) => {
  try {
    const submissions = await Submission.find({ taskId: req.params.taskId })
      .populate('studentId', 'name email profileImage')
      .sort({ createdAt: -1 });
    res.json(submissions);
  } catch (err) {
    res.status(500).send('Server Error');
  }
};

// All submissions for supervisor's tasks (for Submissions page)
// Include tasks created by this supervisor OR tasks for groups assigned to this supervisor
exports.getAllSubmissionsForSupervisor = async (req, res) => {
  try {
    const tasksCreatedByMe = await Task.find({ createdBy: req.user.id }).select('_id').lean();
    const myGroupIds = (await Group.find({ supervisorId: req.user.id }).select('_id').lean()).map(g => g._id);
    const tasksInMyGroups = myGroupIds.length > 0
      ? await Task.find({ groupId: { $in: myGroupIds } }).select('_id').lean()
      : [];
    const idSet = new Set(tasksCreatedByMe.map(t => t._id.toString()));
    tasksInMyGroups.forEach(t => idSet.add(t._id.toString()));
    const taskIds = [...idSet].map(id => new mongoose.Types.ObjectId(id));
    const submissions = await Submission.find({ taskId: { $in: taskIds } })
      .populate('taskId', 'title')
      .populate('studentId', 'name email')
      .sort({ createdAt: -1 });
    res.json(submissions);
  } catch (err) {
    console.error('getAllSubmissionsForSupervisor:', err);
    res.status(500).send('Server Error');
  }
};

// Provide Feedback & Grade
exports.gradeSubmission = async (req, res) => {
  try {
    const { marks, feedback } = req.body;
    const submission = await Submission.findByIdAndUpdate(
      req.params.id,
      {
        $set: {
          grade: { marks: marks != null ? Number(marks) : undefined, feedback: feedback || '', gradedAt: new Date() },
          status: 'Graded'
        }
      },
      { new: true }
    ).populate('studentId', 'name email').populate('taskId', 'title');
    if (!submission) return res.status(404).json({ msg: 'Submission not found' });
    res.json(submission);
  } catch (err) {
    res.status(500).send('Server Error');
  }
};

// controllers/supervisorController.js
exports.getMyGroups = async (req, res) => {
  try {
    // Search by the supervisorId we just fixed in the Admin panel
    const groups = await Group.find({ supervisorId: req.user.id }); 
    
    const groupsWithCounts = await Promise.all(groups.map(async (group) => {
      // FIX: Check if your User model stores group as NAME or ID.
      // If Admin uses group.name, use: { group: group.name }
      // If Admin uses group._id, use: { group: group._id }
      const memberCount = await User.countDocuments({ 
        $or: [
          { group: group._id },
          { group: group.name } 
        ],
        role: 'Student' 
      });

      return {
        ...group.toObject(),
        memberCount
      };
    }));
    
    console.log(`DEBUG: Supervisor ${req.user.id} has ${groups.length} groups.`);
    res.json(groupsWithCounts);
  } catch (err) {
    console.error("DEBUG: getMyGroups Error:", err);
    res.status(500).send('Server Error');
  }
};



// src/controllers/supervisorController.js

exports.getGroupMembers = async (req, res) => {
  try {
    const { groupName } = req.params;

    // Find students assigned to this group name
    const members = await User.find({ 
      group: groupName, 
      role: 'Student' 
    }).select('name email profileImage createdAt status');

    console.log(`DEBUG: Found ${members.length} members for group: ${groupName}`);
    res.json(members);
  } catch (err) {
    console.error("DEBUG: getGroupMembers Error:", err);
    res.status(500).send('Server Error');
  }
};