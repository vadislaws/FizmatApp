import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import authService from '../../services/auth.service';
import i18n from '../../utils/i18n';

export default function Register() {
  const navigate = useNavigate();
  const [theme, setTheme] = useState('dark');
  const [formData, setFormData] = useState({ name: '', email: '', password: '' });
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (authService.isAuthenticated()) navigate('/home');
    setTheme(localStorage.getItem('theme') || 'dark');
  }, [navigate]);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);
    try {
      await authService.register(formData.email, formData.password, formData.name);
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

  return (
    <div style={{ minHeight: '100vh', background: colors.bg, display: 'flex', alignItems: 'center', justifyContent: 'center', padding: '24px' }}>
      <div style={{ width: '100%', maxWidth: '380px' }}>
        <div style={{ textAlign: 'center', marginBottom: '48px' }}>
          <div style={{ width: '72px', height: '72px', background: 'linear-gradient(135deg, #D32F2F 0%, #1A237E 100%)', borderRadius: '20px', display: 'inline-flex', alignItems: 'center', justifyContent: 'center', marginBottom: '16px' }}>
            <svg width="40" height="40" viewBox="0 0 24 24" fill="none"><path d="M12 2L2 7V17L12 22L22 17V7L12 2Z" stroke="white" strokeWidth="2"/><path d="M12 22V12M12 12L22 7M12 12L2 7" stroke="white" strokeWidth="2"/></svg>
          </div>
          <h1 style={{ fontSize: '28px', fontWeight: '600', color: colors.text, margin: 0 }}>{i18n.t('createAccount')}</h1>
        </div>

        <div style={{ background: colors.card, borderRadius: '16px', border: `1px solid ${colors.border}`, padding: '32px' }}>
          {error && <div style={{ marginBottom: '20px', padding: '12px 16px', background: 'rgba(211, 47, 47, 0.1)', border: '1px solid rgba(211, 47, 47, 0.3)', borderRadius: '8px', color: '#D32F2F', fontSize: '14px' }}>{error}</div>}

          <form onSubmit={handleSubmit}>
            <div style={{ marginBottom: '20px' }}>
              <label style={{ display: 'block', fontSize: '14px', fontWeight: '500', color: colors.text, marginBottom: '8px' }}>{i18n.t('name')}</label>
              <input type="text" value={formData.name} onChange={(e) => setFormData({...formData, name: e.target.value})} placeholder={i18n.t('namePlaceholder')} required style={{ width: '100%', padding: '12px 16px', background: colors.input, border: `1px solid ${colors.border}`, borderRadius: '8px', fontSize: '15px', color: colors.text, outline: 'none', boxSizing: 'border-box' }} />
            </div>

            <div style={{ marginBottom: '20px' }}>
              <label style={{ display: 'block', fontSize: '14px', fontWeight: '500', color: colors.text, marginBottom: '8px' }}>{i18n.t('email')}</label>
              <input type="email" value={formData.email} onChange={(e) => setFormData({...formData, email: e.target.value})} placeholder={i18n.t('emailPlaceholder')} required style={{ width: '100%', padding: '12px 16px', background: colors.input, border: `1px solid ${colors.border}`, borderRadius: '8px', fontSize: '15px', color: colors.text, outline: 'none', boxSizing: 'border-box' }} />
            </div>

            <div style={{ marginBottom: '24px' }}>
              <label style={{ display: 'block', fontSize: '14px', fontWeight: '500', color: colors.text, marginBottom: '8px' }}>{i18n.t('password')}</label>
              <div style={{ position: 'relative' }}>
                <input type={showPassword ? 'text' : 'password'} value={formData.password} onChange={(e) => setFormData({...formData, password: e.target.value})} placeholder={i18n.t('passwordPlaceholder')} required style={{ width: '100%', padding: '12px 16px', paddingRight: '48px', background: colors.input, border: `1px solid ${colors.border}`, borderRadius: '8px', fontSize: '15px', color: colors.text, outline: 'none', boxSizing: 'border-box' }} />
                <button type="button" onClick={() => setShowPassword(!showPassword)} style={{ position: 'absolute', right: '12px', top: '50%', transform: 'translateY(-50%)', background: 'none', border: 'none', cursor: 'pointer', fontSize: '20px' }}>
                  {showPassword ? '👁️' : '👁️‍🗨️'}
                </button>
              </div>
            </div>

            <button type="submit" disabled={loading} style={{ width: '100%', padding: '14px', background: loading ? colors.textSecondary : 'linear-gradient(135deg, #D32F2F 0%, #C62828 100%)', color: 'white', border: 'none', borderRadius: '8px', fontSize: '15px', fontWeight: '600', cursor: loading ? 'not-allowed' : 'pointer' }}>
              {loading ? '...' : i18n.t('signUp')}
            </button>

            <div style={{ marginTop: '24px', textAlign: 'center' }}>
              <span style={{ fontSize: '14px', color: colors.textSecondary }}>{i18n.t('alreadyHaveAccount')} </span>
              <button type="button" onClick={() => navigate('/login')} style={{ background: 'none', border: 'none', color: '#D32F2F', fontSize: '14px', fontWeight: '600', cursor: 'pointer', padding: 0 }}>
                {i18n.t('signIn')}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
}