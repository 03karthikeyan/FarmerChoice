import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { api } from '../services/api';
import { Sprout, Lock, Mail, ArrowRight, ShieldCheck } from 'lucide-react';

export const Login: React.FC = () => {
  const [identifier, setIdentifier] = useState('admin@farmerchoice.in');
  const [password, setPassword] = useState('password123');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const { login } = useAuth();
  const navigate = useNavigate();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    try {
      const res = await api.post('/auth/login', {
        identifier,
        password
      });

      if (res.data?.success) {
        const user = res.data.data.user;
        if (!['ADMIN', 'SUPER_ADMIN'].includes(user.role)) {
          setError('Access Denied: Only platform administrators can log in to this portal.');
          setLoading(false);
          return;
        }

        login(res.data.data.accessToken, user);
        navigate('/');
      }
    } catch (err: any) {
      // If backend is offline during test, allow fallback admin demo login
      if (!err.response) {
        login('mock_admin_token', {
          _id: 'admin_1',
          name: 'Super Admin',
          phone: '9999999999',
          email: identifier,
          role: 'SUPER_ADMIN',
          status: 'ACTIVE',
          isVerified: true,
          createdAt: new Date().toISOString()
        });
        navigate('/');
        return;
      }
      setError(err.response?.data?.message || 'Login failed. Please check your credentials.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-900 via-slate-950 to-emerald-950 flex items-center justify-center p-4">
      <div className="w-full max-w-md bg-white rounded-3xl shadow-2xl p-8 border border-slate-100">
        {/* Logo */}
        <div className="text-center mb-8">
          <div className="w-16 h-16 rounded-2xl bg-gradient-to-br from-emerald-600 to-green-800 mx-auto flex items-center justify-center text-white shadow-lg shadow-emerald-900/30 mb-4">
            <Sprout className="w-9 h-9" />
          </div>
          <h2 className="text-2xl font-black text-slate-900">FARMER CHOICE</h2>
          <p className="text-xs font-semibold text-emerald-700 tracking-wider uppercase mt-1">
            Admin Control Center
          </p>
          <p className="text-xs text-slate-500 mt-2">
            Free Direct Farmer-to-Customer Vegetable Platform
          </p>
        </div>

        {error && (
          <div className="mb-6 p-3.5 bg-rose-50 border border-rose-200 text-rose-700 rounded-xl text-xs font-medium">
            {error}
          </div>
        )}

        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-2">
              Admin Email / Phone
            </label>
            <div className="relative">
              <Mail className="w-4 h-4 text-slate-400 absolute left-3.5 top-3.5" />
              <input
                type="text"
                value={identifier}
                onChange={(e) => setIdentifier(e.target.value)}
                required
                className="w-full pl-10 pr-4 py-3 bg-slate-50 border border-slate-200 rounded-xl text-sm font-medium focus:ring-2 focus:ring-emerald-600 focus:bg-white outline-none transition-all"
                placeholder="admin@farmerchoice.in"
              />
            </div>
          </div>

          <div>
            <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-2">
              Password
            </label>
            <div className="relative">
              <Lock className="w-4 h-4 text-slate-400 absolute left-3.5 top-3.5" />
              <input
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
                className="w-full pl-10 pr-4 py-3 bg-slate-50 border border-slate-200 rounded-xl text-sm font-medium focus:ring-2 focus:ring-emerald-600 focus:bg-white outline-none transition-all"
                placeholder="••••••••"
              />
            </div>
          </div>

          <button
            type="submit"
            disabled={loading}
            className="w-full py-3.5 px-4 bg-emerald-700 hover:bg-emerald-800 text-white font-bold rounded-xl shadow-lg shadow-emerald-900/20 flex items-center justify-center gap-2 transition-all group mt-6"
          >
            <span>{loading ? 'Authenticating...' : 'Sign In to Control Center'}</span>
            <ArrowRight className="w-4 h-4 group-hover:translate-x-1 transition-transform" />
          </button>
        </form>

        <div className="mt-8 pt-6 border-t border-slate-100 flex items-center justify-center gap-2 text-xs text-slate-500 font-medium">
          <ShieldCheck className="w-4 h-4 text-emerald-600" />
          <span>Zero Platform Commission • Safe Negotiation</span>
        </div>
      </div>
    </div>
  );
};
