import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import authService from '../../services/auth.service';
import i18n from '../../utils/i18n';

export default function Login() {
  const navigate = useNavigate();
  const [theme, setTheme] = useState('dark');
  const [language, setLanguage] = useState('en');
  const [formData, setFormData] = useState({ email: '', password: '' });
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (authService.isAuthenticated()) {
      navigate('/home');
    }
    setTheme(localStorage.getItem('theme') || 'dark');
    setLanguage(i18n.getLanguage());
  }, [navigate]);

  const toggleTheme = () => {
    const newTheme = theme === 'light' ? 'dark' : 'light';
    setTheme(newTheme);
    localStorage.setItem('theme', newTheme);
  };

  const changeLanguage = (lang) => {
    setLanguage(lang);
    i18n.setLanguage(lang);
    window.location.reload();
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);
    try {
      await authService.login(formData.email, formData.password);
      navigate('/home');
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  const handleGoogleLogin = async () => {
    setLoading(true);
    try {
      await authService.googleLogin();
      navigate('/home');
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  const colors = theme === 'light' 
    ? { bg: '#FAFAFA', card: '#FFFFFF', text: '#212121', textSecondary: '#757575', border: '#E0E0E0', input: '#F5F5F5' }
    : { bg: '#121212', card: '#1E1E1E', text: '#FFFFFF', textSecondary: '#B0B0B0', border: '#2C2C2C', input: '#2C2C2C' };

  const languages = [
    { code: 'en', label: 'EN' },
    { code: 'ru', label: 'RU' },
    { code: 'kk', label: 'KK' },
  ];

  return (
    <div style={{ minHeight: '100vh', background: colors.bg, display: 'flex', alignItems: 'center', justifyContent: 'center', padding: '24px', transition: 'background 0.3s' }}>
      {/* Theme Toggle */}
      <button onClick={toggleTheme} style={{ position: 'fixed', top: '24px', right: '24px', width: '48px', height: '48px', borderRadius: '50%', border: `1px solid ${colors.border}`, background: colors.card, cursor: 'pointer', fontSize: '20px', display: 'flex', alignItems: 'center', justifyContent: 'center', transition: 'all 0.3s' }}>
        {theme === 'light' ? '🌙' : '☀️'}
      </button>

      {/* Language Selector - Oval Buttons */}
      <div style={{ position: 'fixed', top: '24px', left: '24px', display: 'flex', gap: '8px', background: colors.card, padding: '6px', borderRadius: '24px', border: `1px solid ${colors.border}` }}>
        {languages.map(lang => (
          <button
            key={lang.code}
            onClick={() => changeLanguage(lang.code)}
            style={{
              padding: '8px 16px',
              borderRadius: '20px',
              border: 'none',
              background: language === lang.code ? 'linear-gradient(135deg, #D32F2F 0%, #C62828 100%)' : 'transparent',
              color: language === lang.code ? 'white' : colors.text,
              fontSize: '14px',
              fontWeight: '600',
              cursor: 'pointer',
              transition: 'all 0.3s',
            }}
          >
            {lang.label}
          </button>
        ))}
      </div>

      <div style={{ width: '100%', maxWidth: '380px' }}>
        {/* Logo */}
        <div style={{ textAlign: 'center', marginBottom: '48px' }}>
          <div style={{ width: '72px', height: '72px', background: 'linear-gradient(135deg, #D32F2F 0%, #1A237E 100%)', borderRadius: '20px', display: 'inline-flex', alignItems: 'center', justifyContent: 'center', marginBottom: '16px', position: 'relative' }}>
            <svg width="40" height="40" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path d="M12 2L2 7V17L12 22L22 17V7L12 2Z" stroke="white" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
              <path d="M12 22V12M12 12L22 7M12 12L2 7" stroke="white" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
            </svg>
          </div>
          <h1 style={{ fontSize: '28px', fontWeight: '600', color: colors.text, margin: 0 }}>{i18n.t('welcomeBack')}</h1>
        </div>

        {/* Login Card */}
        <div style={{ background: colors.card, borderRadius: '16px', border: `1px solid ${colors.border}`, padding: '32px' }}>
          {error && (
            <div style={{ marginBottom: '20px', padding: '12px 16px', background: 'rgba(211, 47, 47, 0.1)', border: '1px solid rgba(211, 47, 47, 0.3)', borderRadius: '8px', color: '#D32F2F', fontSize: '14px' }}>
              {error}
            </div>
          )}

          <form onSubmit={handleSubmit}>
            <div style={{ marginBottom: '20px' }}>
              <label style={{ display: 'block', fontSize: '14px', fontWeight: '500', color: colors.text, marginBottom: '8px' }}>{i18n.t('email')}</label>
              <input type="email" value={formData.email} onChange={(e) => setFormData({...formData, email: e.target.value})} placeholder={i18n.t('emailPlaceholder')} required style={{ width: '100%', padding: '12px 16px', background: colors.input, border: `1px solid ${colors.border}`, borderRadius: '8px', fontSize: '15px', color: colors.text, outline: 'none', boxSizing: 'border-box' }} onFocus={(e) => e.target.style.borderColor = '#D32F2F'} onBlur={(e) => e.target.style.borderColor = colors.border} />
            </div>

            <div style={{ marginBottom: '12px' }}>
              <label style={{ display: 'block', fontSize: '14px', fontWeight: '500', color: colors.text, marginBottom: '8px' }}>{i18n.t('password')}</label>
              <div style={{ position: 'relative' }}>
                <input type={showPassword ? 'text' : 'password'} value={formData.password} onChange={(e) => setFormData({...formData, password: e.target.value})} placeholder={i18n.t('passwordPlaceholder')} required style={{ width: '100%', padding: '12px 16px', paddingRight: '48px', background: colors.input, border: `1px solid ${colors.border}`, borderRadius: '8px', fontSize: '15px', color: colors.text, outline: 'none', boxSizing: 'border-box' }} onFocus={(e) => e.target.style.borderColor = '#D32F2F'} onBlur={(e) => e.target.style.borderColor = colors.border} />
                <button type="button" onClick={() => setShowPassword(!showPassword)} style={{ position: 'absolute', right: '12px', top: '50%', transform: 'translateY(-50%)', background: 'none', border: 'none', cursor: 'pointer', fontSize: '20px' }}>
                  {showPassword ? '👁️' : '👁️‍🗨️'}
                </button>
              </div>
            </div>

            <div style={{ textAlign: 'right', marginBottom: '24px' }}>
              <button type="button" onClick={() => navigate('/forgot-password')} style={{ background: 'none', border: 'none', color: '#D32F2F', fontSize: '14px', fontWeight: '500', cursor: 'pointer', padding: 0 }}>
                {i18n.t('forgotPassword')}
              </button>
            </div>

            <button type="submit" disabled={loading} style={{ width: '100%', padding: '14px', background: loading ? colors.textSecondary : 'linear-gradient(135deg, #D32F2F 0%, #C62828 100%)', color: 'white', border: 'none', borderRadius: '8px', fontSize: '15px', fontWeight: '600', cursor: loading ? 'not-allowed' : 'pointer', marginBottom: '16px' }}>
              {loading ? '...' : i18n.t('signIn')}
            </button>

            <div style={{ display: 'flex', alignItems: 'center', margin: '24px 0', gap: '12px' }}>
              <div style={{ flex: 1, height: '1px', background: colors.border }}></div>
              <span style={{ fontSize: '13px', color: colors.textSecondary }}>{i18n.t('or')}</span>
              <div style={{ flex: 1, height: '1px', background: colors.border }}></div>
            </div>

            <button type="button" onClick={handleGoogleLogin} disabled={loading} style={{ width: '100%', padding: '14px', background: colors.card, border: `1px solid ${colors.border}`, borderRadius: '8px', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '12px', cursor: 'pointer', fontSize: '15px', fontWeight: '600', color: colors.text }}>
              <svg width="20" height="20" viewBox="0 0 24 24"><path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/><path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/><path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"/><path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/></svg>
              <span>{i18n.t('continueWithGoogle')}</span>
            </button>

            <div style={{ marginTop: '24px', textAlign: 'center' }}>
              <span style={{ fontSize: '14px', color: colors.textSecondary }}>{i18n.t('dontHaveAccount')} </span>
              <button type="button" onClick={() => navigate('/register')} style={{ background: 'none', border: 'none', color: '#D32F2F', fontSize: '14px', fontWeight: '600', cursor: 'pointer', padding: 0 }}>
                {i18n.t('signUp')}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
}