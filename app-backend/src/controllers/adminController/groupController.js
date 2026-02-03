// const Group = require('../../models/group');
// const User = require('../../models/User');

// Create Group
// exports.createGroup = async (req, res) => {
//     try {
//         const { name, description, academicYear } = req.body;

//         // Check if group exists
//         let group = await Group.findOne({ name });
//         if (group) return res.status(400).json({ msg: 'Group already exists' });

//         group = new Group({
//             name,
//             description,
//             academicYear,
//             createdBy: req.user.id
//         });

//         await group.save();
//         res.status(201).json(group);
//     } catch (err) {
//         console.error(err);
//         res.status(500).send('Server Error');
//     }
// };



// exports.createGroup = async (req, res) => {
//     try {
//         // 1. Extract supervisorId along with other fields
//         const { name, description, academicYear, supervisorId } = req.body;

//         // 2. Check if group exists
//         let group = await Group.findOne({ name });
//         if (group) return res.status(400).json({ msg: 'Group already exists' });

//         // 3. Create the group with the assigned supervisorId
//         group = new Group({
//             name,
//             description,
//             academicYear,
//             createdBy: req.user.id, // The Admin
//             supervisorId: supervisorId // The Assigned Supervisor
//         });

//         await group.save();
//         res.status(201).json(group);
//     } catch (err) {
//         console.error(err);
//         res.status(500).send('Server Error');
//     }
// };
// // Get All Groups
// exports.getAllGroups = async (req, res) => {
//     try {
//         const groups = await Group.find();

//         // Count members by matching the "group" string in User model with the group's Name
//         // We filter for role: 'Student' to avoid ghost counts from supervisors if they share names
//         const groupsWithCounts = await Promise.all(groups.map(async (group) => {
//             const memberCount = await User.countDocuments({
//                 group: group.name,
//                 role: 'Student'
//             });

//             return {
//                 ...group.toObject(),
//                 memberCount
//             };
//         }));

//         res.json(groupsWithCounts);
//     } catch (err) {
//         console.error(err);
//         res.status(500).send('Server Error');
//     }
// };





const Group = require('../../models/group');
const User = require('../../models/User');

// Create Group (Updated to accept optional supervisorId at creation)
exports.createGroup = async (req, res) => {
    try {
        const { name, description, academicYear, supervisorId } = req.body;

        let group = await Group.findOne({ name });
        if (group) return res.status(400).json({ msg: 'Group already exists' });

        group = new Group({
            name,
            description,
            academicYear,
            createdBy: req.user.id,
            supervisorId: supervisorId || null // Can be assigned later
        });

        await group.save();
        res.status(201).json(group);
    } catch (err) {
        console.error(err);
        res.status(500).send('Server Error');
    }
};

/**
 * NEW: Assign to Supervisor
 * Use this in your "Assign Supervisor" section in the Admin Panel
 */
exports.assignSupervisor = async (req, res) => {
    try {
        const { groupId, supervisorId } = req.body;

        // 1. Verify the group exists
        const group = await Group.findById(groupId);
        if (!group) return res.status(404).json({ msg: 'Group not found' });

        // 2. Verify the supervisor exists and has the correct role
        const supervisor = await User.findOne({ _id: supervisorId, role: 'Supervisor' });
        if (!supervisor) {
            return res.status(404).json({ msg: 'Supervisor not found or invalid role' });
        }

        // 3. Update the group's supervisorId field
        group.supervisorId = supervisorId;
        await group.save();

        res.json({ msg: 'Supervisor assigned to group successfully', group });
    } catch (err) {
        console.error(err);
        res.status(500).send('Server Error');
    }
};

// Get All Groups
exports.getAllGroups = async (req, res) => {
    try {
        // We populate 'supervisorId' to show the supervisor's name in the Admin list
        const groups = await Group.find().populate('supervisorId', 'name email');

        const groupsWithCounts = await Promise.all(groups.map(async (group) => {
            const memberCount = await User.countDocuments({
                group: group.name,
                role: 'Student'
            });

            return {
                ...group.toObject(),
                memberCount
            };
        }));

        res.json(groupsWithCounts);
    } catch (err) {
        console.error(err);
        res.status(500).send('Server Error');
    }
};


// Assign Members to Group
exports.assignMembers = async (req, res) => {
    try {
        const { groupId } = req.params;
        const { emails } = req.body;

        if (!emails || !Array.isArray(emails)) {
            return res.status(400).json({ msg: 'Please provide a list of emails' });
        }

        // Find the group by ID to get its NAME
        const group = await Group.findById(groupId);
        if (!group) return res.status(404).json({ msg: 'Group not found' });

        // Update users matching emails to have this Group NAME
        await User.updateMany(
            { email: { $in: emails } },
            { $set: { group: group.name } }
        );

        res.json({ msg: 'Members assigned successfully' });
    } catch (err) {
        console.error(err);
        res.status(500).send('Server Error');
    }
};

// Delete Group
exports.deleteGroup = async (req, res) => {
    try {
        const { groupId } = req.params;
        const group = await Group.findById(groupId);
        if (!group) return res.status(404).json({ msg: 'Group not found' });

        // Clear group field for all users associated with this group name
        await User.updateMany(
            { group: group.name },
            { $set: { group: null } }
        );

        // Delete the group
        await group.deleteOne();

        res.json({ msg: 'Group deleted and members freed' });
    } catch (err) {
        console.error(err);
        res.status(500).send('Server Error');
    }
};
