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

// Bulk Import Users from CSV
exports.importUsers = async (req, res) => {
  try {
    if (!req.file || !req.file.buffer) {
      return res.status(400).json({ msg: 'No CSV file uploaded' });
    }
    const csvText = req.file.buffer.toString('utf8');
    const lines = csvText.split(/\r?\n/).filter(line => line.trim());
    if (lines.length < 2) {
      return res.status(400).json({ msg: 'CSV must have header row and at least one data row' });
    }

    const headers = lines[0].split(',').map(h => h.trim().toLowerCase());
    const nameIdx = headers.findIndex(h => h === 'name');
    const emailIdx = headers.findIndex(h => h === 'email');
    const passwordIdx = headers.findIndex(h => h === 'password');
    const roleIdx = headers.findIndex(h => h === 'role');
    const studentIdIdx = headers.findIndex(h => h === 'studentid');
    const phoneIdx = headers.findIndex(h => h === 'phone');

    if (nameIdx < 0 || emailIdx < 0 || passwordIdx < 0 || roleIdx < 0) {
      return res.status(400).json({
        msg: 'CSV must have columns: name, email, password, role (optional: studentId, phone)'
      });
    }

    const results = { created: 0, skipped: [], errors: [] };

    for (let i = 1; i < lines.length; i++) {
      const vals = lines[i].split(',').map(v => v.trim());
      const name = vals[nameIdx] || '';
      const email = vals[emailIdx] || '';
      const password = vals[passwordIdx] || '';
      let role = (vals[roleIdx] || 'Student').trim();
      const studentId = studentIdIdx >= 0 ? (vals[studentIdIdx] || '') : '';
      const phone = phoneIdx >= 0 ? (vals[phoneIdx] || '') : '';

      if (!name || !email || !password) {
        results.errors.push(`Row ${i + 1}: name, email, password required`);
        continue;
      }

      role = ['Admin', 'Supervisor', 'Student'].includes(role) ? role : 'Student';

      const existing = await User.findOne({ email });
      if (existing) {
        results.skipped.push(email);
        continue;
      }

      if (role === 'Student' && studentId) {
        const existingStudent = await User.findOne({ studentId });
        if (existingStudent) {
          results.skipped.push(`Student ${studentId}`);
          continue;
        }
      }

      try {
        const user = new User({
          name,
          email,
          password,
          role,
          phone: phone || undefined,
          studentId: role === 'Student' && studentId ? studentId : undefined,
          status: true
        });
        await user.save();
        results.created++;
      } catch (err) {
        results.errors.push(`Row ${i + 1} (${email}): ${err.message}`);
      }
    }

    res.status(200).json({
      msg: 'Import completed',
      created: results.created,
      skipped: results.skipped,
      errors: results.errors
    });
  } catch (err) {
    console.error('DEBUG: importUsers error:', err);
    res.status(500).json({ msg: 'Server Error: ' + err.message });
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