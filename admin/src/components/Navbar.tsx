import React from 'react';
import { Bell, ShieldCheck, Search } from 'lucide-react';
import { useAuth } from '../context/AuthContext';

export const Navbar: React.FC<{ title: string }> = ({ title }) => {
  const { user } = useAuth();

  return (
    <header className="h-16 bg-white border-b border-slate-200 flex items-center justify-between px-8 shrink-0">
      <div className="flex items-center gap-4">
        <h2 className="text-xl font-bold text-slate-900">{title}</h2>
        <span className="hidden sm:inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-semibold bg-emerald-100 text-emerald-800 border border-emerald-200">
          <ShieldCheck className="w-3.5 h-3.5" />
          Direct Market System Active
        </span>
      </div>

      <div className="flex items-center gap-4">
        <div className="text-right hidden md:block">
          <p className="text-xs font-semibold text-slate-800">Zero Payment Gateway</p>
          <p className="text-[11px] text-slate-500">Free Direct Platform</p>
        </div>
        <div className="h-8 w-px bg-slate-200"></div>
        <div className="flex items-center gap-2">
          <div className="w-8 h-8 rounded-full bg-emerald-600 text-white flex items-center justify-center font-bold text-xs">
            {user?.name?.charAt(0) || 'A'}
          </div>
          <span className="text-sm font-medium text-slate-700 hidden sm:inline-block">
            {user?.name || 'Admin'}
          </span>
        </div>
      </div>
    </header>
  );
};
