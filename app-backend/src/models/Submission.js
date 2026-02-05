const mongoose = require('mongoose');

const SubmissionSchema = new mongoose.Schema({
  taskId: { type: mongoose.Schema.Types.ObjectId, ref: 'Task', required: true },
  studentId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  fileUrl: { type: String },
  description: { type: String },
  externalLink: { type: String },
  status: { type: String, enum: ['Submitted', 'Pending', 'Graded'], default: 'Submitted' },
  grade: {
    marks: { type: Number },
    feedback: { type: String },
    gradedAt: { type: Date }
  }
}, { timestamps: true });

module.exports = mongoose.models.Submission || mongoose.model('Submission', SubmissionSchema);
