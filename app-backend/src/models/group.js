const mongoose = require('mongoose');
// models/Group.js
const GroupSchema = new mongoose.Schema({
  name: { type: String, required: true },
  description: String,
  academicYear: String,
  createdBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' }, // The Admin
  supervisorId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' }, // The Assigned Supervisor
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Group', GroupSchema);