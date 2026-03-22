import React, { useState } from 'react';
import { Link, useLocation, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import './Layout.css';

const Icon = ({ type }) => {
  const paths = {
    dashboard: 'M4 12h6V4H4v8Zm0 8h6v-6H4v6Zm10 0h6V12h-6v8Zm0-16v6h6V4h-6Z',
    users: 'M16 11c1.66 0 2.99-1.57 2.99-3.5S17.66 4 16 4s-3 1.57-3 3.5S14.34 11 16 11Zm-8 0c1.66 0 2.99-1.57 2.99-3.5S9.66 4 8 4 5 5.57 5 7.5 6.34 11 8 11Zm0 2c-2.33 0-7 1.17-7 3.5V20h14v-3.5C15 14.17 10.33 13 8 13Zm8 0c-.29 0-.62.02-.97.05 1.16.84 1.97 1.95 1.97 3.45V20h6v-3.5c0-2.33-4.67-3.5-7-3.5Z',
    groups: 'M3 6h18v2H3V6Zm4 5h10v2H7v-2Zm-2 5h14v2H5v-2Z',
    shops: 'M5 4h14l1 5v2h-1v8H5v-8H4V9l1-5Zm2 7v6h10v-6H7Zm-.37-2h10.74l-.6-3H7.23l-.6 3Z',
    categories: 'M4 6h7v7H4V6Zm9 0h7v7h-7V6Zm-9 9h7v5H4v-5Zm9 0h7v5h-7v-5Z',
    campaigns: 'M7 2h2v2h6V2h2v2h3v16H4V4h3V2Zm11 8H6v8h12v-8Zm0-4H6v2h12V6Z',
    surveys: 'M6 4h12a2 2 0 0 1 2 2v12l-4-2-4 2-4-2-4 2V6a2 2 0 0 1 2-2Zm0 2v8.76l2-.99 4 2 4-2 2 .99V6H6Z',
    results: 'M5 5h14v14H5V5Zm2 2v10h10V7H7Zm1 6h2v2H8v-2Zm3-3h2v5h-2v-5Zm3-2h2v7h-2V8Z',
  };

  return (
    <svg viewBox="0 0 24 24" aria-hidden="true" className="nav-icon-svg">
      <path d={paths[type]} />
    </svg>
  );
};

const menuItems = [
  { path: '/', label: 'Хянах самбар', icon: 'dashboard' },
  { path: '/auditors', label: 'Аудиторууд', icon: 'users' },
  { path: '/groups', label: 'Группүүд', icon: 'groups' },
  { path: '/tradeshops', label: 'Дэлгүүрүүд', icon: 'shops' },
  { path: '/categories', label: 'Ангилал', icon: 'categories' },
  { path: '/campaigns', label: 'Кампанит ажил', icon: 'campaigns' },
  { path: '/surveys', label: 'Судалгаа', icon: 'surveys' },
  { path: '/audit-results', label: 'Аудитын үр дүн', icon: 'results' },
];

const isActiveRoute = (pathname, itemPath) => {
  if (itemPath === '/') {
    return pathname === '/';
  }
  return pathname === itemPath || pathname.startsWith(`${itemPath}/`);
};

const Layout = ({ children }) => {
  const [sidebarOpen, setSidebarOpen] = useState(true);
  const { user, logout } = useAuth();
  const location = useLocation();
  const navigate = useNavigate();

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  const currentTitle =
    menuItems.find((item) => isActiveRoute(location.pathname, item.path))?.label || 'Аудит Систем';

  return (
    <div className="layout">
      <aside className={`sidebar ${sidebarOpen ? 'open' : 'closed'}`}>
        <div className="sidebar-header">
          <div className="brand-block">
            <h1 className="logo">Аудит Систем</h1>
          </div>
          <button
            className="toggle-btn"
            type="button"
            onClick={() => setSidebarOpen((value) => !value)}
            aria-label="Цэс нээх эсвэл хаах"
          >
            <span />
          </button>
        </div>

        <nav className="sidebar-nav">
          {menuItems.map((item) => (
            <Link
              key={item.path}
              to={item.path}
              className={`nav-item ${isActiveRoute(location.pathname, item.path) ? 'active' : ''}`}
            >
              <Icon type={item.icon} />
              {sidebarOpen && <span className="nav-label">{item.label}</span>}
            </Link>
          ))}
        </nav>

        <div className="sidebar-footer">
          <div className="profile-card">
            <div className="profile-avatar" />
            {sidebarOpen && (
              <div className="user-info">
                <span className="user-name">{user?.name || 'Админ Хэрэглэгч'}</span>
                <span className="user-role">{user?.is_admin ? 'Админ' : 'Аудитор'}</span>
              </div>
            )}
          </div>
          <button className="logout-btn" type="button" onClick={handleLogout}>
            {sidebarOpen ? 'Гарах' : '>'}
          </button>
        </div>
      </aside>

      <main className="main-content">
        <header className="top-header">
          <h2 className="page-title">{currentTitle}</h2>
          <div className="header-right">
            <span className="header-dot" />
            <span className="welcome-text">Тавтай морил, {user?.name || 'Админ Хэрэглэгч'}</span>
          </div>
        </header>
        <div className="content-area">{children}</div>
      </main>
    </div>
  );
};

export default Layout;
