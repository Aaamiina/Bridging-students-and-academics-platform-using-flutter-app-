const User = require('../../models/User');
const Group = require('../../models/group');
const Task = require('../../models/task');
const Submission = require('../../models/gradesub');

exports.getGlobalStats = async (req, res) => {
    try {
        const usersCount = await User.countDocuments();
        const supervisorsCount = await User.countDocuments({ role: 'Supervisor' });
        const groupsCount = await Group.countDocuments();
        const tasksCount = await Task.countDocuments();
        const submissionsCount = await Submission.countDocuments();

        res.json({
            users: usersCount,
            supervisors: supervisorsCount,
            groups: groupsCount,
            tasks: tasksCount,
            submissions: submissionsCount
        });
    } catch (err) {
        res.status(500).json({ msg: 'Server Error fetching stats' });
    }
};

exports.getAllTasks = async (req, res) => {
    try {
        const tasks = await Task.find().populate('groupId', 'name').populate('createdBy', 'name');
        res.json(tasks);
    } catch (err) {
        res.status(500).json({ msg: 'Server Error fetching tasks' });
    }
};

exports.getAllSubmissions = async (req, res) => {
    try {
        const submissions = await Submission.find().populate('taskId', 'title').populate('studentId', 'name email');
        res.json(submissions);
    } catch (err) {
        res.status(500).json({ msg: 'Server Error fetching submissions' });
    }
};
