/// Centralized validation and clear error messages for the app.
class Validators {
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Email must be valid format. Use for Academic/Admin login.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return 'Invalid email. Please enter a valid email address (e.g. name@university.edu).';
    }
    return null;
  }

  /// University ID: letters and numbers only, no spaces or symbols.
  static String? universityId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your University ID';
    }
    final trimmed = value.trim();
    if (!RegExp(r'^[A-Za-z0-9]+$').hasMatch(trimmed)) {
      return 'University ID can only contain letters and numbers (no spaces or symbols)';
    }
    if (trimmed.length < 3) {
      return 'University ID is too short';
    }
    return null;
  }

  /// For Student login: accept either University ID or email.
  static String? idOrEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your University ID or email';
    }
    final trimmed = value.trim();
    if (trimmed.contains('@')) {
      if (!_emailRegex.hasMatch(trimmed)) {
        return 'Please enter a valid email address';
      }
    } else {
      if (!RegExp(r'^[A-Za-z0-9]+$').hasMatch(trimmed)) {
        return 'University ID can only contain letters and numbers';
      }
      if (trimmed.length < 3) {
        return 'University ID is too short';
      }
    }
    return null;
  }

  /// Password: required and minimum length.
  static String? password(String? value, {int minLength = 3}) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    return null;
  }

  /// Required field (generic).
  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Numbers only (e.g. phone, grade).
  static String? numbersOnly(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) return null;
    if (!RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
      return '$fieldName can only contain numbers';
    }
    return null;
  }

  /// Name: letters and spaces only.
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (!RegExp(r"^[a-zA-Z\s\.\-']+$").hasMatch(value.trim())) {
      return 'Name can only contain letters and spaces';
    }
    return null;
  }

  /// Phone: digits, spaces, dashes, plus only.
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (!RegExp(r'^[0-9+\-\s]+$').hasMatch(value.trim())) {
      return 'Please enter a valid phone number (numbers, +, -, spaces only)';
    }
    return null;
  }

  /// Task title: required and must contain at least one letter (not only numbers).
  static String? taskTitle(String? value) {
    final err = required(value, 'Task title');
    if (err != null) return err;
    final trimmed = value!.trim();
    if (!RegExp(r'[a-zA-Z]').hasMatch(trimmed)) {
      return 'Task title must contain letters, not only numbers';
    }
    return null;
  }

  /// Task description: required and must contain at least one letter (not only numbers).
  static String? taskDescription(String? value) {
    final err = required(value, 'Description');
    if (err != null) return err;
    final trimmed = value!.trim();
    if (!RegExp(r'[a-zA-Z]').hasMatch(trimmed)) {
      return 'Description must contain letters, not only numbers';
    }
    return null;
  }

  /// Deadline date: YYYY-MM-DD format, must be a valid date and today or in the future.
  static String? deadline(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a deadline';
    }
    final trimmed = value.trim();
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(trimmed)) {
      return 'Enter a valid date (YYYY-MM-DD)';
    }
    final parts = trimmed.split('-');
    final y = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final d = int.tryParse(parts[2]);
    if (y == null || m == null || d == null || m < 1 || m > 12 || d < 1 || d > 31) {
      return 'Enter a valid date (YYYY-MM-DD)';
    }
    DateTime? date;
    try {
      date = DateTime(y, m, d);
    } catch (_) {
      return 'Enter a valid date (YYYY-MM-DD)';
    }
    if (date.year != y || date.month != m || date.day != d) {
      return 'Enter a valid date (YYYY-MM-DD)';
    }
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    if (date.isBefore(today)) {
      return 'Deadline must be today or a future date';
    }
    return null;
  }
}
