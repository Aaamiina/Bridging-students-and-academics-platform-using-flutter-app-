const User = require('../models/User');
const jwt = require('jsonwebtoken');

// Login Mechanism
exports.login = async (req, res) => {
  const { email, password, studentId } = req.body; // Accept email OR studentId

  try {
    let user;
    // Check if login is via Student ID (if provided) or Email
    if (studentId) {
      user = await User.findOne({ studentId });
    } else {
      user = await User.findOne({ email });
    }

    // 2. Check if user exists and if their status is true (Active)
    // Updated from .isActive to .status to match your Model
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

// TEMPORARY: Seed Admin for testing
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
      role: 'SUPER_ADMIN',
      status: true
    });

    await user.save();
    res.json({ msg: 'Admin seeded successfully! Use admin@example.com / 123 to log in.' });
  } catch (err) {
    res.status(500).send('Seed Error: ' + err.message);
  }
};

// Profile Management
exports.updateProfile = async (req, res) => {
  try {
    const { name, email, password } = req.body;

    // Find the user first to ensure we trigger the 'save' hook if password changes
    const user = await User.findById(req.user.id);
    if (!user) return res.status(404).json({ msg: 'User not found' });

    if (name) user.name = name;
    if (email) user.email = email;
    if (password) user.password = password; // The pre-save hook in User.js will hash this automatically

    await user.save();

    res.json({
      id: user._id,
      name: user.name,
      email: user.email,
      role: user.role,
      profileImage: user.profileImage
    });
  } catch (err) {
    res.status(500).send('Server Error');
  }
};