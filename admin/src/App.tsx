import React from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider, useAuth } from './context/AuthContext';
import { Layout } from './components/Layout';
import { Dashboard } from './pages/Dashboard';
import { Farmers } from './pages/Farmers';
import { Customers } from './pages/Customers';
import { Vegetables } from './pages/Vegetables';
import { Deals } from './pages/Deals';
import { Reviews } from './pages/Reviews';
import { Reports } from './pages/Reports';
import { SupportTickets } from './pages/SupportTickets';
import { Analytics } from './pages/Analytics';
import { AuditLogs } from './pages/AuditLogs';
import { Login } from './pages/Login';

const ProtectedRoute: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const { token, isLoading } = useAuth();
  if (isLoading) return <div className="p-8 text-center text-slate-500">Loading...</div>;
  if (!token) return <Navigate to="/login" replace />;
  return <>{children}</>;
};

export const App: React.FC = () => {
  return (
    <AuthProvider>
      <BrowserRouter>
        <Routes>
          <Route path="/login" element={<Login />} />
          <Route
            path="/"
            element={
              <ProtectedRoute>
                <Layout />
              </ProtectedRoute>
            }
          >
            <Route index element={<Dashboard />} />
            <Route path="farmers" element={<Farmers />} />
            <Route path="customers" element={<Customers />} />
            <Route path="vegetables" element={<Vegetables />} />
            <Route path="deals" element={<Deals />} />
            <Route path="reviews" element={<Reviews />} />
            <Route path="reports" element={<Reports />} />
            <Route path="support" element={<SupportTickets />} />
            <Route path="analytics" element={<Analytics />} />
            <Route path="audit-logs" element={<AuditLogs />} />
          </Route>
          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </BrowserRouter>
    </AuthProvider>
  );
};
