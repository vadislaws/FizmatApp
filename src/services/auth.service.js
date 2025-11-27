// Mock Authentication Service (uses localStorage as database)
// TODO: Replace with real backend API calls

const USERS_KEY = 'fizmat_users';
const TOKEN_KEY = 'fizmat_token';
const USER_KEY = 'fizmat_user';

// Initialize mock users database
const initDB = () => {
  if (!localStorage.getItem(USERS_KEY)) {
    localStorage.setItem(USERS_KEY, JSON.stringify([]));
  }
};

// Generate JWT-like token
const generateToken = (userId) => {
  return btoa(JSON.stringify({
    userId,
    timestamp: Date.now(),
    expires: Date.now() + (7 * 24 * 60 * 60 * 1000), // 7 days
  }));
};

// Validate token
const validateToken = (token) => {
  try {
    const decoded = JSON.parse(atob(token));
    return decoded.expires > Date.now();
  } catch {
    return false;
  }
};

// Auth Service
const authService = {
  // Register new user
  register: async (email, password, name) => {
    initDB();
    
    return new Promise((resolve, reject) => {
      setTimeout(() => {
        const users = JSON.parse(localStorage.getItem(USERS_KEY));
        
        // Check if user exists
        if (users.find(u => u.email === email)) {
          reject({ message: 'User already exists' });
          return;
        }
        
        // Create new user
        const newUser = {
          id: Date.now().toString(),
          email,
          password, // In real app, hash this!
          name,
          createdAt: new Date().toISOString(),
        };
        
        users.push(newUser);
        localStorage.setItem(USERS_KEY, JSON.stringify(users));
        
        // Auto login after register
        const token = generateToken(newUser.id);
        localStorage.setItem(TOKEN_KEY, token);
        localStorage.setItem(USER_KEY, JSON.stringify({
          id: newUser.id,
          email: newUser.email,
          name: newUser.name,
        }));
        
        resolve({
          token,
          user: {
            id: newUser.id,
            email: newUser.email,
            name: newUser.name,
          },
        });
      }, 800);
    });
  },

  // Login
  login: async (email, password) => {
    initDB();
    
    return new Promise((resolve, reject) => {
      setTimeout(() => {
        const users = JSON.parse(localStorage.getItem(USERS_KEY));
        const user = users.find(u => u.email === email && u.password === password);
        
        if (!user) {
          reject({ message: 'Invalid credentials' });
          return;
        }
        
        const token = generateToken(user.id);
        localStorage.setItem(TOKEN_KEY, token);
        localStorage.setItem(USER_KEY, JSON.stringify({
          id: user.id,
          email: user.email,
          name: user.name,
        }));
        
        resolve({
          token,
          user: {
            id: user.id,
            email: user.email,
            name: user.name,
          },
        });
      }, 800);
    });
  },

  // Google OAuth (mock)
  googleLogin: async () => {
    return new Promise((resolve) => {
      setTimeout(() => {
        const mockUser = {
          id: 'google_' + Date.now(),
          email: 'user@gmail.com',
          name: 'Google User',
        };
        
        const token = generateToken(mockUser.id);
        localStorage.setItem(TOKEN_KEY, token);
        localStorage.setItem(USER_KEY, JSON.stringify(mockUser));
        
        resolve({ token, user: mockUser });
      }, 1000);
    });
  },

  // Logout
  logout: () => {
    localStorage.removeItem(TOKEN_KEY);
    localStorage.removeItem(USER_KEY);
  },

  // Check if user is logged in
  isAuthenticated: () => {
    const token = localStorage.getItem(TOKEN_KEY);
    return token && validateToken(token);
  },

  // Get current user
  getCurrentUser: () => {
    const userStr = localStorage.getItem(USER_KEY);
    return userStr ? JSON.parse(userStr) : null;
  },

  // Password reset (mock)
  resetPassword: async (email) => {
    return new Promise((resolve, reject) => {
      setTimeout(() => {
        const users = JSON.parse(localStorage.getItem(USERS_KEY) || '[]');
        const user = users.find(u => u.email === email);
        
        if (!user) {
          reject({ message: 'User not found' });
          return;
        }
        
        // In real app, send email with reset link
        resolve({ message: 'Password reset link sent to your email' });
      }, 1000);
    });
  },
};

export default authService;