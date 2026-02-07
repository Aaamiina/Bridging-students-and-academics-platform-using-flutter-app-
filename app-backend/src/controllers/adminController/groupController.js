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
const mongoose =require("mongoose");

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

//   NEW: Assign to Supervisor

exports.assignSupervisor = async (req, res) => {
    console.log("DEBUG: assignSupervisor hit with body:", req.body);
    try {
        const { groupId, supervisorId } = req.body;

        // 1. Validate ObjectId format to prevent cast errors
        if (!mongoose.Types.ObjectId.isValid(groupId) || !mongoose.Types.ObjectId.isValid(supervisorId)) {
            console.log("DEBUG: Invalid ID format received");
            return res.status(400).json({ 
                msg: 'Invalid Group ID or Supervisor ID format. Ensure you are sending 24-character hex IDs.' 
            });
        }

        // 2. Verify the group exists
        const group = await Group.findById(groupId);
        if (!group) {
            console.log("DEBUG: Group not found for ID:", groupId);
            return res.status(404).json({ msg: 'Group not found in database' });
        }

        // 3. Verify the supervisor exists and has the correct role
        const supervisor = await User.findOne({ _id: supervisorId, role: 'Supervisor' });
        if (!supervisor) {
            console.log("DEBUG: Supervisor not found or wrong role for ID:", supervisorId);
            return res.status(404).json({ msg: 'Supervisor not found or user is not a Supervisor' });
        }

        // 4. Update and Save
        group.supervisorId = supervisorId;
        await group.save();

        // 5. Optionally update the User record if you track the group there too
        // await User.findByIdAndUpdate(supervisorId, { group: group.name });

        console.log("DEBUG: Assignment successful!");
        res.json({ 
            msg: 'Supervisor assigned to group successfully', 
            groupName: group.name,
            supervisorName: supervisor.name 
        });

    } catch (err) {
        console.error("DEBUG: Catch block error:", err);
        res.status(500).json({ msg: 'Server Error', error: err.message });
    }
};

// Unassign / Remove supervisor from group (makes group available for other supervisors)
exports.unassignSupervisor = async (req, res) => {
    try {
        const { groupId } = req.params;
        if (!mongoose.Types.ObjectId.isValid(groupId)) {
            return res.status(400).json({ msg: 'Invalid Group ID format' });
        }
        const group = await Group.findById(groupId);
        if (!group) return res.status(404).json({ msg: 'Group not found' });
        group.supervisorId = null;
        await group.save();
        res.json({ msg: 'Supervisor removed from group', groupName: group.name });
    } catch (err) {
        res.status(500).json({ msg: 'Server Error', error: err.message });
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
