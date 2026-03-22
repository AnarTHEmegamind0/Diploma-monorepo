import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { initAdmin, login as apiLogin } from '../services/api';
import './Login.css';

const Login = () => {
  const navigate = useNavigate();
  const { login } = useAuth();
  const [phone, setPhone] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [setupInfo, setSetupInfo] = useState(null);

  const handleSubmit = async (event) => {
    event.preventDefault();
    setLoading(true);
    setError('');

    try {
      const response = await apiLogin(phone, password);
      login(response.access_token, {
        id: response.auditor_id,
        name: response.auditor_name,
        is_admin: response.is_admin,
      });
      navigate('/');
    } catch (err) {
      setError(err.response?.data?.detail || 'Нэвтрэх үйлдэл амжилтгүй боллоо.');
    } finally {
      setLoading(false);
    }
  };

  const handleInitAdmin = async () => {
    setLoading(true);
    setError('');
    try {
      const response = await initAdmin();
      setSetupInfo(response);
      setPhone(response.phone);
      setPassword(response.password);
    } catch (err) {
      setError(err.response?.data?.detail || 'Анхны админ үүсгэж чадсангүй.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="login-container">
      <div className="login-frame">
        <div className="login-card">
          <div className="login-header">
            <h1>Аудит Систем</h1>
            <p>Системд нэвтэрч аудитын мэдээллээ удирдана уу.</p>
          </div>

          {error && <div className="error-message">{error}</div>}
          {setupInfo && (
            <div className="success-message">
              Админ үүссэн. Утас: {setupInfo.phone} Нууц үг: {setupInfo.password}
            </div>
          )}

          <form className="login-form" onSubmit={handleSubmit}>
            <div className="form-group">
              <label htmlFor="phone">Утас</label>
              <input id="phone" type="text" value={phone} onChange={(event) => setPhone(event.target.value)} required />
            </div>
            <div className="form-group">
              <label htmlFor="password">Нууц үг</label>
              <input id="password" type="password" value={password} onChange={(event) => setPassword(event.target.value)} required />
            </div>
            <button className="login-btn" type="submit" disabled={loading}>
              {loading ? 'Түр хүлээнэ үү...' : 'Нэвтрэх'}
            </button>
          </form>

          <div className="setup-panel">
            <p>Системийг анх удаа ашиглаж байгаа бол эхний админ үүсгэнэ үү.</p>
            <button className="setup-btn" type="button" onClick={handleInitAdmin} disabled={loading}>
              Анхны админ үүсгэх
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Login;
