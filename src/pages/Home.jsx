import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import authService from '../services/auth.service';

export default function Home() {
  const navigate = useNavigate();
  const [user, setUser] = useState(null);
  const [theme, setTheme] = useState('dark');

  useEffect(() => {
    if (!authService.isAuthenticated()) {
      navigate('/login');
      return;
    }
    setUser(authService.getCurrentUser());
    setTheme(localStorage.getItem('theme') || 'dark');
  }, [navigate]);

  const handleLogout = () => {
    authService.logout();
    navigate('/login');
  };

  const colors = theme === 'light' 
    ? { bg: '#FAFAFA', card: '#FFFFFF', text: '#212121', textSecondary: '#757575', border: '#E0E0E0' }
    : { bg: '#121212', card: '#1E1E1E', text: '#FFFFFF', textSecondary: '#B0B0B0', border: '#2C2C2C' };

  return (
    <div style={{ minHeight: '100vh', background: colors.bg, padding: '24px' }}>
      <div style={{ maxWidth: '1200px', margin: '0 auto' }}>
        {/* Header */}
        <div style={{ background: colors.card, borderRadius: '16px', border: `1px solid ${colors.border}`, padding: '24px', marginBottom: '24px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <div>
            <h1 style={{ fontSize: '32px', fontWeight: '700', color: colors.text, margin: '0 0 8px 0' }}>
              Welcome, {user?.name || 'User'}! 🎉
            </h1>
            <p style={{ fontSize: '16px', color: colors.textSecondary, margin: 0 }}>{user?.email}</p>
          </div>
          <button onClick={handleLogout} style={{ padding: '12px 24px', background: 'linear-gradient(135deg, #D32F2F 0%, #C62828 100%)', color: 'white', border: 'none', borderRadius: '8px', fontSize: '15px', fontWeight: '600', cursor: 'pointer' }}>
            Logout
          </button>
        </div>

        {/* Placeholder Content */}
        <div style={{ background: colors.card, borderRadius: '16px', border: `1px solid ${colors.border}`, padding: '48px', textAlign: 'center' }}>
          <div style={{ width: '120px', height: '120px', background: 'linear-gradient(135deg, #D32F2F 0%, #1A237E 100%)', borderRadius: '30px', display: 'inline-flex', alignItems: 'center', justifyContent: 'center', marginBottom: '24px' }}>
            <svg width="60" height="60" viewBox="0 0 24 24" fill="none"><path d="M12 2L2 7V17L12 22L22 17V7L12 2Z" stroke="white" strokeWidth="2"/><path d="M12 22V12M12 12L22 7M12 12L2 7" stroke="white" strokeWidth="2"/></svg>
          </div>
          <h2 style={{ fontSize: '28px', fontWeight: '600', color: colors.text, marginBottom: '12px' }}>Home Page Coming Soon!</h2>
          <p style={{ fontSize: '16px', color: colors.textSecondary, marginBottom: '32px', maxWidth: '600px', margin: '0 auto' }}>
            This is a placeholder. The main home screen with all features (Schedule, Clubs, Olympiads, etc.) will be built next.
          </p>
          <div style={{ display: 'inline-block', padding: '16px 32px', background: colors.bg, borderRadius: '12px', marginTop: '24px' }}>
            <p style={{ fontSize: '14px', color: colors.text, margin: 0, fontWeight: '600' }}>✅ Authentication working</p>
            <p style={{ fontSize: '14px', color: colors.text, margin: '8px 0 0 0', fontWeight: '600' }}>✅ Auto-login enabled</p>
            <p style={{ fontSize: '14px', color: colors.text, margin: '8px 0 0 0', fontWeight: '600' }}>✅ Multi-language support</p>
          </div>
        </div>
      </div>
    </div>
  );
}