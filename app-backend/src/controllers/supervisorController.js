const Task = require('../models/task');
const Submission = require('../models/Submission');
const Group = require('../models/group');

// Create Task & Distribute
exports.createTask = async (req, res) => {
  try {
    const { title, description, deadline, groupId } = req.body;
    const task = new Task({
      title, description, deadline, groupId,
      createdBy: req.user.id
    });
    await task.save();
    res.json(task);
  } catch (err) {
    res.status(500).send('Server Error');
  }
};

// Review Submissions
exports.getSubmissionsByTask = async (req, res) => {
  try {
    const submissions = await Submission.find({ taskId: req.params.taskId }).populate('studentId', 'name email');
    res.json(submissions);
  } catch (err) {
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
        grade: { marks, feedback, gradedAt: Date.now() },
        status: 'Graded' 
      },
      { new: true }
    );
    res.json(submission);
  } catch (err) {
    res.status(500).send('Server Error');
  }
};