const SubmissionSchema = new mongoose.Schema({
  taskId: { type: mongoose.Schema.Types.ObjectId, ref: 'Task' },
  studentId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  fileUrl: String,
  description: String,
  status: { type: String, enum: ['Submitted', 'Pending', 'Graded'], default: 'Submitted' },
  grade: {
    marks: Number,
    feedback: String,
    gradedAt: Date
  }
}, { timestamps: true });
module.exports = mongoose.model('Submission', SubmissionSchema);