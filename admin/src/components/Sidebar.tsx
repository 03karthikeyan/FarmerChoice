import React from 'react';
import { NavLink } from 'react-router-dom';
import {
  LayoutDashboard,
  Users,
  UserCheck,
  ShoppingBag,
  Handshake,
  Star,
  AlertTriangle,
  HelpCircle,
  BarChart3,
  ShieldAlert,
  ShieldCheck,
  LogOut,
  Sprout
} from 'lucide-react';
import { useAuth } from '../context/AuthContext';

export const Sidebar: React.FC = () => {
  const { logout, user } = useAuth();

  const navItems = [
    { name: 'Dashboard', path: '/', icon: LayoutDashboard },
    { name: 'Farmers Verification', path: '/farmers', icon: UserCheck },
    { name: 'Customers', path: '/customers', icon: Users },
    { name: 'Vegetable Listings', path: '/vegetables', icon: ShoppingBag },
    { name: 'Deals Oversight', path: '/deals', icon: Handshake },
    { name: 'Verified Reviews', path: '/reviews', icon: Star },
    { name: 'Safety Reports', path: '/reports', icon: AlertTriangle },
    { name: 'Support Tickets', path: '/support', icon: HelpCircle },
    { name: 'Market Analytics', path: '/analytics', icon: BarChart3 },
    { name: 'Audit Logs', path: '/audit-logs', icon: ShieldAlert },
    { name: 'Admin & Staff', path: '/admins', icon: ShieldCheck },
  ];

  return (
    <aside className="w-64 bg-slate-900 text-slate-300 flex flex-col shrink-0 border-r border-slate-800">
      {/* Brand Header */}
      <div className="h-16 flex items-center px-6 gap-3 border-b border-slate-800 bg-slate-950/60">
        <div className="w-9 h-9 rounded-xl bg-gradient-to-br from-brand-500 to-brand-700 flex items-center justify-center text-white shadow-md shadow-brand-900/30">
          <Sprout className="w-5 h-5 text-white" />
        </div>
        <div>
          <h1 className="font-bold text-white text-base leading-tight tracking-tight">FARMER CHOICE</h1>
          <p className="text-[11px] text-brand-400 font-medium tracking-wider uppercase">Admin Control</p>
        </div>
      </div>

      {/* Navigation links */}
      <div className="flex-1 overflow-y-auto py-4 px-3 space-y-1">
        {navItems.map((item) => (
          <NavLink
            key={item.path}
            to={item.path}
            className={({ isActive }) =>
              `flex items-center gap-3 px-3.5 py-2.5 rounded-lg text-sm font-medium transition-all ${
                isActive
                  ? 'bg-brand-600 text-white shadow-md shadow-brand-950/30'
                  : 'text-slate-400 hover:text-white hover:bg-slate-800/70'
              }`
            }
          >
            <item.icon className="w-4 h-4 shrink-0" />
            <span>{item.name}</span>
          </NavLink>
        ))}
      </div>

      {/* User / Logout */}
      <div className="p-4 border-t border-slate-800 bg-slate-950/40">
        <div className="flex items-center gap-3 mb-3">
          <div className="w-8 h-8 rounded-full bg-brand-700 text-white flex items-center justify-center font-bold text-xs">
            {user?.name?.charAt(0) || 'A'}
          </div>
          <div className="flex-1 min-w-0">
            <p className="text-xs font-semibold text-white truncate">{user?.name || 'Administrator'}</p>
            <p className="text-[11px] text-slate-400 truncate">{user?.email || 'admin@farmerchoice.in'}</p>
          </div>
        </div>
        <button
          onClick={logout}
          className="w-full flex items-center justify-center gap-2 px-3 py-2 rounded-lg text-xs font-medium text-red-400 hover:text-red-300 hover:bg-red-950/30 border border-red-900/30 transition-colors"
        >
          <LogOut className="w-3.5 h-3.5" />
          <span>Sign Out</span>
        </button>
      </div>
    </aside>
  );
};
