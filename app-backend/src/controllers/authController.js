const User = require('../models/User');
const jwt = require('jsonwebtoken');

// Login: uses users from database only (Admin creates Students; no seed data for students)
exports.login = async (req, res) => {
  const { email, password, studentId } = req.body;

  try {
    let user;
    if (studentId !== undefined && studentId !== null && String(studentId).trim() !== '') {
      // Student login: find admin-created user (role Student) by Student ID or by email
      const identifier = String(studentId).trim();
      user = await User.findOne({ studentId: identifier, role: 'Student' });
      if (!user) {
        user = await User.findOne({ email: identifier, role: 'Student' });
      }
    } else {
      user = await User.findOne({ email });
    }

    if (!user || !user.status) {
      return res.status(401).json({ msg: 'Invalid credentials or account inactive' });
    }

    // 3. Use the helper method from the User Model to compare passwords
    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      return res.status(401).json({ msg: 'Invalid credentials' });
    }

    // 4. Role-based token generation (Admin, Supervisor, or Student)
    const token = jwt.sign(
      { id: user._id, role: user.role, group: user.group },
      process.env.JWT_SECRET,
      { expiresIn: '1d' }
    );

    // 5. Return token and user info for Flutter to handle navigation
    res.json({
      token,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        role: user.role,
        group: user.group,
        profileImage: user.profileImage,
        studentId: user.studentId
      }
    });
  } catch (err) {
    res.status(500).send('Server Error');
  }
};

// TEMPORARY: Seed Admin for testing (role must be 'Admin' to match User schema enum)
exports.seedAdmin = async (req, res) => {
  try {
    const adminEmail = 'admin@example.com';
    let user = await User.findOne({ email: adminEmail });
    if (user) {
      return res.json({ msg: 'Admin already exists', user: { email: user.email, role: user.role } });
    }

    user = new User({
      name: 'Super Admin',
      email: adminEmail,
      password: '123', // Will be hashed by pre-save
      role: 'Admin', // Must match User schema enum: Admin, Supervisor, Student
      status: true
    });

    await user.save();
    res.json({ msg: 'Admin seeded successfully! Use admin@example.com / 123 to log in.' });
  } catch (err) {
    res.status(500).json({ msg: 'Seed Error: ' + err.message });
  }
};

// Profile Management
exports.updateProfile = async (req, res) => {
  try {
    const { name, email, password, phone } = req.body;

    const user = await User.findById(req.user.id);
    if (!user) return res.status(404).json({ msg: 'User not found' });

    if (name != null) user.name = name;
    if (email != null) user.email = email;
    if (password != null && password !== '') user.password = password;
    if (phone != null) user.phone = phone;

    await user.save();

    res.json({
      id: user._id,
      name: user.name,
      email: user.email,
      role: user.role,
      profileImage: user.profileImage,
      phone: user.phone
    });
  } catch (err) {
    res.status(500).send('Server Error');
  }
};