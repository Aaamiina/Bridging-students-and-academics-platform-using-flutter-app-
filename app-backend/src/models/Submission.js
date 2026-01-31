const mongoose = require('mongoose');

const SubmissionSchema = new mongoose.Schema({
  assignmentId: { type: mongoose.Schema.Types.ObjectId, ref: 'Assignment', required: true },
  studentId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  externalLink: { type: String }, // For GitHub/Drive links
  submissionText: { type: String },
  status: { type: String, enum: ['Submitted', 'Late', 'Pending'], default: 'Submitted' },
  grade: { type: String, default: 'Not Graded' },
  feedback: { type: String, default: '' }
}, { timestamps: true });

module.exports = mongoose.model('Submission', SubmissionSchema);