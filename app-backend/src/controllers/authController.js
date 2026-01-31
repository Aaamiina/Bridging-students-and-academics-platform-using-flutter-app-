const User = require('../models/User');
const jwt = require('jsonwebtoken');

// Login Mechanism
exports.login = async (req, res) => {
  const { email, password } = req.body;
  try {
    // 1. Find user by email
    const user = await User.findOne({ email });

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
      user: { id: user._id, name: user.name, role: user.role, group: user.group }
    });
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
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
      role: user.role
    });
  } catch (err) {
    res.status(500).send('Server Error');
  }
};