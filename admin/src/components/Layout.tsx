import React from 'react';
import { Outlet, useLocation } from 'react-router-dom';
import { Sidebar } from './Sidebar';
import { Navbar } from './Navbar';

const getTitleFromPath = (pathname: string): string => {
  switch (pathname) {
    case '/':
      return 'Marketplace Overview';
    case '/farmers':
      return 'Farmer Verification & Profiles';
    case '/customers':
      return 'Customer Directory';
    case '/vegetables':
      return 'Vegetables Moderation & Featured';
    case '/deals':
      return 'Direct Deals Oversight';
    case '/reviews':
      return 'Verified Reviews Audit';
    case '/reports':
      return 'Safety & Moderation Reports';
    case '/support':
      return 'Customer & Farmer Support Tickets';
    case '/analytics':
      return 'Platform Activity Analytics';
    case '/audit-logs':
      return 'Administrator Audit Trail';
    default:
      return 'Farmer Choice Control Panel';
  }
};

export const Layout: React.FC = () => {
  const location = useLocation();
  const title = getTitleFromPath(location.pathname);

  return (
    <div className="flex h-screen w-full bg-slate-50 overflow-hidden font-sans">
      <Sidebar />
      <div className="flex-1 flex flex-col min-w-0 overflow-hidden">
        <Navbar title={title} />
        <main className="flex-1 overflow-y-auto p-6 md:p-8 bg-slate-50">
          <Outlet />
        </main>
      </div>
    </div>
  );
};
