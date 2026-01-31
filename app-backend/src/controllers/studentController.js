const Task = require('../models/task');
const Submission = require('../models/Submission');

// View Assigned Tasks
exports.getMyTasks = async (req, res) => {
  try {
    const tasks = await Task.find({ groupId: req.user.group });
    res.json(tasks);
  } catch (err) {
    res.status(500).send('Server Error');
  }
};

// Submit Work
exports.submitTask = async (req, res) => {
  try {
    const { taskId, fileUrl, description, externalLink } = req.body;
    const submission = new Submission({
      taskId,
      studentId: req.user.id,
      fileUrl,
      description,
      externalLink,
      submittedAt: Date.now(),
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
      .populate('taskId', 'title')
      .select('grade status taskId');
    res.json(submissions);
  } catch (err) {
    res.status(500).send('Server Error');
  }
};