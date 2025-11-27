import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import authService from '../../services/auth.service';
import i18n from '../../utils/i18n';

export default function ForgotPassword() {
  const navigate = useNavigate();
  const [theme, setTheme] = useState('dark');
  const [email, setEmail] = useState('');
  const [success, setSuccess] = useState(false);
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    setTheme(localStorage.getItem('theme') || 'dark');
  }, []);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);
    try {
      await authService.resetPassword(email);
      setSuccess(true);
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
          <h1 style={{ fontSize: '28px', fontWeight: '600', color: colors.text, margin: 0 }}>{i18n.t('resetPassword')}</h1>
        </div>

        <div style={{ background: colors.card, borderRadius: '16px', border: `1px solid ${colors.border}`, padding: '32px' }}>
          {success ? (
            <div>
              <div style={{ padding: '12px 16px', background: 'rgba(76, 175, 80, 0.1)', border: '1px solid rgba(76, 175, 80, 0.3)', borderRadius: '8px', color: '#4CAF50', fontSize: '14px', marginBottom: '20px' }}>
                {i18n.t('resetLinkSent')}
              </div>
              <button onClick={() => navigate('/login')} style={{ width: '100%', padding: '14px', background: 'linear-gradient(135deg, #D32F2F 0%, #C62828 100%)', color: 'white', border: 'none', borderRadius: '8px', fontSize: '15px', fontWeight: '600', cursor: 'pointer' }}>
                {i18n.t('backToLogin')}
              </button>
            </div>
          ) : (
            <form onSubmit={handleSubmit}>
              {error && <div style={{ marginBottom: '20px', padding: '12px 16px', background: 'rgba(211, 47, 47, 0.1)', border: '1px solid rgba(211, 47, 47, 0.3)', borderRadius: '8px', color: '#D32F2F', fontSize: '14px' }}>{error}</div>}

              <div style={{ marginBottom: '24px' }}>
                <label style={{ display: 'block', fontSize: '14px', fontWeight: '500', color: colors.text, marginBottom: '8px' }}>{i18n.t('email')}</label>
                <input type="email" value={email} onChange={(e) => setEmail(e.target.value)} placeholder={i18n.t('emailPlaceholder')} required style={{ width: '100%', padding: '12px 16px', background: colors.input, border: `1px solid ${colors.border}`, borderRadius: '8px', fontSize: '15px', color: colors.text, outline: 'none', boxSizing: 'border-box' }} />
              </div>

              <button type="submit" disabled={loading} style={{ width: '100%', padding: '14px', background: loading ? colors.textSecondary : 'linear-gradient(135deg, #D32F2F 0%, #C62828 100%)', color: 'white', border: 'none', borderRadius: '8px', fontSize: '15px', fontWeight: '600', cursor: loading ? 'not-allowed' : 'pointer', marginBottom: '16px' }}>
                {loading ? '...' : i18n.t('sendResetLink')}
              </button>

              <button type="button" onClick={() => navigate('/login')} style={{ width: '100%', padding: '14px', background: 'none', border: `1px solid ${colors.border}`, borderRadius: '8px', fontSize: '15px', fontWeight: '600', cursor: 'pointer', color: colors.text }}>
                {i18n.t('backToLogin')}
              </button>
            </form>
          )}
        </div>
      </div>
    </div>
  );
}