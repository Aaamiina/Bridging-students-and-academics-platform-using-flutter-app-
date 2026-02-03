const User = require('../../models/User');

// Create New User
exports.createUser = async (req, res) => {
  console.log("DEBUG: createUser called. Body:", req.body);
  console.log("DEBUG: createUser called. File:", req.file);
  try {
    const { name, email, password, role, group, phone, studentId } = req.body;

    // 1. Check if user already exists
    let user = await User.findOne({ email });
    if (user) return res.status(400).json({ msg: 'User already exists' });

    // Additional check for studentId if role is Student
    if (role === 'Student' && studentId) {
      let existingStudent = await User.findOne({ studentId });
      if (existingStudent) return res.status(400).json({ msg: 'Student ID already exists' });
    }

    // 2. Handle the Image File
    let profileImage = "";
    if (req.file) {
      profileImage = req.file.path.replace(/\\/g, "/");
    }

    // 3. Create the user
    user = new User({
      name,
      email,
      password,
      role,
      group,
      phone,
      studentId, // Save studentId
      profileImage
    });

    await user.save();

    res.status(201).json({
      msg: 'User created successfully',
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        studentId: user.studentId,
        profileImage: user.profileImage
      }
    });
  } catch (err) {
    console.error("DEBUG: Error in createUser:", err);
    if (err.code === 11000) {
      return res.status(400).json({ msg: 'Duplicate key error', error: err.message });
    }
    res.status(500).send('Server Error: ' + err.message);
  }
};

// Get All Users
exports.getUsers = async (req, res) => {
  try {
    const users = await User.find().select('-password');
    res.json(users);
  } catch (err) {
    res.status(500).send('Server Error');
  }
};

// Update User Details
exports.updateUser = async (req, res) => {
  try {
    const { name, email, role, phone, group, status, password, studentId } = req.body;

    let user = await User.findById(req.params.id);
    if (!user) return res.status(404).json({ msg: 'User not found' });

    // Handle Image Update
    if (req.file) {
      user.profileImage = req.file.path.replace(/\\/g, "/");
    }

    // Update fields if provided
    if (name !== undefined) user.name = name;
    if (email !== undefined) user.email = email;
    if (role !== undefined) user.role = role;
    if (phone !== undefined) user.phone = phone;
    if (group !== undefined) user.group = group;
    if (studentId !== undefined) user.studentId = studentId;
    user.status = status !== undefined ? status : user.status;

    if (password) user.password = password;

    await user.save();
    res.json({ msg: 'User updated successfully', user });
  } catch (err) {
    console.error("DEBUG: Error in updateUser:", err);
    res.status(500).send('Server Error');
  }
};

// Toggle User Status (Active/Disabled)
exports.toggleUserStatus = async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) return res.status(404).json({ msg: 'User not found' });

    user.status = !user.status;
    await user.save();
    res.json({ msg: `User ${user.status ? 'activated' : 'deactivated'}`, status: user.status });
  } catch (err) {
    res.status(500).send('Server Error');
  }
};

// Delete User
exports.deleteUser = async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) return res.status(404).json({ msg: 'User not found' });

    console.log(`DEBUG: Deleting user ${user.name} (${user.email}) from group: ${user.group || 'None'}`);

    // Delete the user
    await user.deleteOne();

    console.log(`DEBUG: User ${user.name} successfully deleted`);
    res.json({ msg: 'User removed successfully' });
  } catch (err) {
    console.error('DEBUG: Error deleting user:', err);
    res.status(500).send('Server Error');
  }
};