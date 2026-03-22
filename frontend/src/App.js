import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider, useAuth } from './context/AuthContext';
import Layout from './components/Layout';
import Login from './pages/Login';
import Dashboard from './pages/Dashboard';
import Auditors from './pages/Auditors';
import Groups from './pages/Groups';
import Tradeshops from './pages/Tradeshops';
import Categories from './pages/Categories';
import Campaigns from './pages/Campaigns';
import Surveys from './pages/Surveys';
import SurveyBuilder from './pages/SurveyBuilder';
import AuditResults from './pages/AuditResults';
import './App.css';

// Protected Route wrapper
const ProtectedRoute = ({ children }) => {
  const { isAuthenticated, loading } = useAuth();

  if (loading) {
    return (
      <div className="loading-container">
        <div className="loading-spinner"></div>
        <p>Ачааллаж байна...</p>
      </div>
    );
  }

  if (!isAuthenticated) {
    return <Navigate to="/login" replace />;
  }

  return <Layout>{children}</Layout>;
};

// Public Route wrapper (redirects to dashboard if already logged in)
const PublicRoute = ({ children }) => {
  const { isAuthenticated, loading } = useAuth();

  if (loading) {
    return (
      <div className="loading-container">
        <div className="loading-spinner"></div>
        <p>Ачааллаж байна...</p>
      </div>
    );
  }

  if (isAuthenticated) {
    return <Navigate to="/" replace />;
  }

  return children;
};

function AppRoutes() {
  return (
    <Routes>
      {/* Public Routes */}
      <Route 
        path="/login" 
        element={
          <PublicRoute>
            <Login />
          </PublicRoute>
        } 
      />

      {/* Protected Routes */}
      <Route 
        path="/" 
        element={
          <ProtectedRoute>
            <Dashboard />
          </ProtectedRoute>
        } 
      />
      <Route 
        path="/auditors" 
        element={
          <ProtectedRoute>
            <Auditors />
          </ProtectedRoute>
        } 
      />
      <Route 
        path="/groups" 
        element={
          <ProtectedRoute>
            <Groups />
          </ProtectedRoute>
        } 
      />
      <Route 
        path="/tradeshops" 
        element={
          <ProtectedRoute>
            <Tradeshops />
          </ProtectedRoute>
        } 
      />
      <Route 
        path="/categories" 
        element={
          <ProtectedRoute>
            <Categories />
          </ProtectedRoute>
        } 
      />
      <Route 
        path="/campaigns" 
        element={
          <ProtectedRoute>
            <Campaigns />
          </ProtectedRoute>
        } 
      />
      <Route 
        path="/surveys" 
        element={
          <ProtectedRoute>
            <Surveys />
          </ProtectedRoute>
        } 
      />
      <Route
        path="/surveys/:surveyId/builder"
        element={
          <ProtectedRoute>
            <SurveyBuilder />
          </ProtectedRoute>
        }
      />
      <Route 
        path="/audit-results" 
        element={
          <ProtectedRoute>
            <AuditResults />
          </ProtectedRoute>
        } 
      />

      {/* Catch all - redirect to dashboard */}
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  );
}

function App() {
  return (
    <Router>
      <AuthProvider>
        <AppRoutes />
      </AuthProvider>
    </Router>
  );
}

export default App;
