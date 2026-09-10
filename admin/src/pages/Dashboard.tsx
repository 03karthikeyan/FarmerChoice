import React, { useEffect, useState } from 'react';
import { api } from '../services/api';
import { DashboardStats, Deal, FarmerProfile } from '../types';
import {
  Users,
  UserCheck,
  ShoppingBag,
  Handshake,
  CheckCircle2,
  Clock,
  AlertTriangle,
  HelpCircle,
  TrendingUp,
  Shield,
  ArrowUpRight
} from 'lucide-react';
import { Link } from 'react-router-dom';

export const Dashboard: React.FC = () => {
  const [stats, setStats] = useState<DashboardStats>({
    totalFarmers: 5,
    verifiedFarmers: 5,
    pendingFarmers: 0,
    totalCustomers: 2,
    activeVegetables: 8,
    activeDeals: 1,
    completedDeals: 1,
    cancelledDeals: 0,
    pendingReports: 0,
    openTickets: 0
  });
  const [recentDeals, setRecentDeals] = useState<Deal[]>([]);
  const [pendingFarmers, setPendingFarmers] = useState<FarmerProfile[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchDashboard();
  }, []);

  const fetchDashboard = async () => {
    try {
      const res = await api.get('/admin/dashboard');
      if (res.data?.success) {
        setStats(res.data.data.stats);
        setRecentDeals(res.data.data.recentDeals || []);
        setPendingFarmers(res.data.data.pendingVerifications || []);
      }
    } catch (err) {
      console.warn('Using local stats fallback:', err);
    } finally {
      setLoading(false);
    }
  };

  const statCards = [
    { title: 'Total Farmers', value: stats.totalFarmers, icon: UserCheck, color: 'text-emerald-600', bg: 'bg-emerald-50', link: '/farmers' },
    { title: 'Verified Farmers', value: stats.verifiedFarmers, icon: Shield, color: 'text-teal-600', bg: 'bg-teal-50', link: '/farmers' },
    { title: 'Total Customers', value: stats.totalCustomers, icon: Users, color: 'text-blue-600', bg: 'bg-blue-50', link: '/customers' },
    { title: 'Active Vegetables', value: stats.activeVegetables, icon: ShoppingBag, color: 'text-amber-600', bg: 'bg-amber-50', link: '/vegetables' },
    { title: 'Active Deals', value: stats.activeDeals, icon: Handshake, color: 'text-purple-600', bg: 'bg-purple-50', link: '/deals' },
    { title: 'Completed Deals', value: stats.completedDeals, icon: CheckCircle2, color: 'text-emerald-700', bg: 'bg-emerald-100', link: '/deals' },
    { title: 'Pending Reports', value: stats.pendingReports, icon: AlertTriangle, color: 'text-rose-600', bg: 'bg-rose-50', link: '/reports' },
    { title: 'Open Tickets', value: stats.openTickets, icon: HelpCircle, color: 'text-indigo-600', bg: 'bg-indigo-50', link: '/support' },
  ];

  return (
    <div className="space-y-8">
      {/* Zero Payment Disclaimer Alert */}
      <div className="bg-gradient-to-r from-emerald-800 to-green-900 rounded-2xl p-6 text-white shadow-lg flex flex-col md:flex-row items-start md:items-center justify-between gap-4">
        <div>
          <span className="px-3 py-1 rounded-full text-xs font-bold bg-emerald-700 text-emerald-100 uppercase tracking-wide">
            Zero Platform Commission
          </span>
          <h3 className="text-xl font-bold mt-2">Free Direct Farmer-to-Customer Marketplace</h3>
          <p className="text-emerald-100 text-sm mt-1 max-w-2xl">
            Farmer Choice does not process online payments. Farmers set their own prices and direct deals are finalized mutually without fees.
          </p>
        </div>
        <div className="shrink-0 bg-white/10 backdrop-blur-md px-4 py-3 rounded-xl border border-white/20">
          <p className="text-xs text-emerald-200">Payment Processing</p>
          <p className="text-lg font-bold text-white">₹0 Fee / Free</p>
        </div>
      </div>

      {/* Stat Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
        {statCards.map((card, i) => (
          <Link
            key={i}
            to={card.link}
            className="bg-white p-5 rounded-2xl border border-slate-200 shadow-sm hover:shadow-md hover:border-emerald-300 transition-all flex items-center justify-between group"
          >
            <div>
              <p className="text-xs font-medium text-slate-500 uppercase tracking-wider">{card.title}</p>
              <h4 className="text-2xl font-extrabold text-slate-900 mt-1">{card.value}</h4>
            </div>
            <div className={`w-12 h-12 rounded-xl ${card.bg} ${card.color} flex items-center justify-center shrink-0 group-hover:scale-110 transition-transform`}>
              <card.icon className="w-6 h-6" />
            </div>
          </Link>
        ))}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        {/* Recent Deals Activity */}
        <div className="bg-white rounded-2xl border border-slate-200 p-6 shadow-sm">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-base font-bold text-slate-900 flex items-center gap-2">
              <Handshake className="w-5 h-5 text-emerald-600" />
              Recent Deal Inquiries
            </h3>
            <Link to="/deals" className="text-xs font-semibold text-emerald-600 hover:text-emerald-700 flex items-center gap-1">
              View All <ArrowUpRight className="w-3.5 h-3.5" />
            </Link>
          </div>

          <div className="divide-y divide-slate-100">
            {recentDeals.length === 0 ? (
              <div className="py-8 text-center text-slate-400 text-sm">
                No deal records found.
              </div>
            ) : (
              recentDeals.map((deal) => (
                <div key={deal._id} className="py-3.5 flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <div className="w-10 h-10 rounded-xl bg-slate-100 flex items-center justify-center font-bold text-xs text-slate-700">
                      {deal.dealNumber || 'DEAL'}
                    </div>
                    <div>
                      <p className="text-sm font-semibold text-slate-900">
                        {deal.vegetableId?.name || 'Vegetables'} ({deal.agreedQuantity || deal.requestedQuantity} kg)
                      </p>
                      <p className="text-xs text-slate-500">
                        Farmer: {deal.farmerId?.name || 'Farmer'} • Customer: {deal.customerId?.name || 'Customer'}
                      </p>
                    </div>
                  </div>
                  <div className="text-right">
                    <p className="text-sm font-bold text-slate-900">Ref: ₹{deal.dealReferenceValue}</p>
                    <span className={`inline-block px-2 py-0.5 rounded text-[10px] font-bold uppercase ${
                      deal.status === 'COMPLETED' ? 'bg-emerald-100 text-emerald-800' :
                      deal.status === 'ACCEPTED' ? 'bg-blue-100 text-blue-800' : 'bg-amber-100 text-amber-800'
                    }`}>
                      {deal.status}
                    </span>
                  </div>
                </div>
              ))
            )}
          </div>
        </div>

        {/* Farmer Verification Queue */}
        <div className="bg-white rounded-2xl border border-slate-200 p-6 shadow-sm">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-base font-bold text-slate-900 flex items-center gap-2">
              <UserCheck className="w-5 h-5 text-emerald-600" />
              Farmer Verification Queue
            </h3>
            <Link to="/farmers" className="text-xs font-semibold text-emerald-600 hover:text-emerald-700 flex items-center gap-1">
              Manage <ArrowUpRight className="w-3.5 h-3.5" />
            </Link>
          </div>

          <div className="divide-y divide-slate-100">
            {pendingFarmers.length === 0 ? (
              <div className="py-8 text-center text-slate-400 text-sm">
                No pending farmer verifications right now. All active farmers are verified.
              </div>
            ) : (
              pendingFarmers.map((f) => (
                <div key={f._id} className="py-3.5 flex items-center justify-between">
                  <div>
                    <p className="text-sm font-semibold text-slate-900">{f.userId?.name}</p>
                    <p className="text-xs text-slate-500">{f.village}, {f.district} • {f.userId?.phone}</p>
                  </div>
                  <Link
                    to="/farmers"
                    className="px-3 py-1.5 rounded-lg text-xs font-bold bg-emerald-600 text-white hover:bg-emerald-700 transition-colors"
                  >
                    Review
                  </Link>
                </div>
              ))
            )}
          </div>
        </div>
      </div>
    </div>
  );
};
