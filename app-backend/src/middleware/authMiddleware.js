const jwt = require('jsonwebtoken');

const protect = (req, res, next) => {
  console.log("DEBUG: Auth Middleware - Start");
  let token = req.header('Authorization');
  console.log("DEBUG: Raw Auth Header:", token);

  if (token && token.startsWith('Bearer ')) {
    token = token.slice(7, token.length);
    console.log("DEBUG: Auth Middleware - Token Extracted");
  } else if (token) {
    console.log("DEBUG: Auth Middleware - WARNING: Token present but no Bearer prefix");
  }

  if (!token) {
    console.log("DEBUG: Auth Middleware - No Token");
    return res.status(401).json({ msg: 'No token, authorization denied' });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;
    console.log("DEBUG: Auth Middleware - User Verified:", req.user.id);
    next();
  } catch (err) {
    console.error("DEBUG: Auth Middleware - Token Invalid:", err.message);
    res.status(401).json({ msg: 'Token is not valid' });
  }
};

const authorize = (...roles) => {
  return (req, res, next) => {
    if (!roles.includes(req.user.role)) {
      return res.status(403).json({ msg: 'User role not authorized' });
    }
    next();
  };
};

module.exports = { protect, authorize };