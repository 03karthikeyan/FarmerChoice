import React, { useEffect, useState } from 'react';
import { api } from '../services/api';
import { FarmerProfile } from '../types';
import { UserCheck, Shield, ShieldAlert, Star, Phone, MapPin, Check, X, Ban, RefreshCw } from 'lucide-react';

export const Farmers: React.FC = () => {
  const [farmers, setFarmers] = useState<FarmerProfile[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedFarmer, setSelectedFarmer] = useState<FarmerProfile | null>(null);

  useEffect(() => {
    fetchFarmers();
  }, []);

  const fetchFarmers = async () => {
    setLoading(true);
    try {
      const res = await api.get('/admin/farmers');
      if (res.data?.success) {
        setFarmers(res.data.data);
      }
    } catch (err) {
      console.warn('Fallback loading farmers:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleVerify = async (farmerId: string) => {
    try {
      await api.patch(`/admin/farmers/${farmerId}/verify`);
      fetchFarmers();
    } catch (err: any) {
      alert(err.response?.data?.message || 'Verification failed');
    }
  };

  const handleReject = async (farmerId: string) => {
    const reason = prompt('Enter rejection reason:');
    if (!reason) return;
    try {
      await api.patch(`/admin/farmers/${farmerId}/reject`, { reason });
      fetchFarmers();
    } catch (err: any) {
      alert(err.response?.data?.message || 'Rejection failed');
    }
  };

  const handleToggleStatus = async (userId: string, currentStatus: string) => {
    const newStatus = currentStatus === 'ACTIVE' ? 'SUSPENDED' : 'ACTIVE';
    try {
      await api.patch(`/admin/users/${userId}/status`, { status: newStatus });
      fetchFarmers();
    } catch (err: any) {
      alert(err.response?.data?.message || 'Failed to update user status');
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
        <div>
          <h3 className="text-xl font-bold text-slate-900">Farmer Directory & Verification</h3>
          <p className="text-sm text-slate-500">Review farm credentials, approve verified farmer badges, and manage farmer trust.</p>
        </div>
        <button
          onClick={fetchFarmers}
          className="flex items-center gap-2 px-4 py-2 bg-white border border-slate-200 rounded-xl text-xs font-semibold text-slate-700 hover:bg-slate-50 shadow-sm"
        >
          <RefreshCw className="w-3.5 h-3.5" /> Refresh List
        </button>
      </div>

      {/* Farmers Table */}
      <div className="bg-white rounded-2xl border border-slate-200 overflow-hidden shadow-sm">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-sm">
            <thead className="bg-slate-50 text-slate-500 text-xs uppercase tracking-wider border-b border-slate-200">
              <tr>
                <th className="px-6 py-4">Farmer</th>
                <th className="px-6 py-4">Location</th>
                <th className="px-6 py-4">Verification</th>
                <th className="px-6 py-4">Trust & Deals</th>
                <th className="px-6 py-4">Account Status</th>
                <th className="px-6 py-4 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100 text-slate-700">
              {farmers.length === 0 ? (
                <tr>
                  <td colSpan={6} className="px-6 py-12 text-center text-slate-400">
                    No farmer profiles found.
                  </td>
                </tr>
              ) : (
                farmers.map((farmer) => (
                  <tr key={farmer._id} className="hover:bg-slate-50/80 transition-colors">
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-3">
                        <img
                          src={farmer.userId?.profileImage || 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100'}
                          alt=""
                          className="w-10 h-10 rounded-full object-cover border border-emerald-200 shrink-0"
                        />
                        <div>
                          <p className="font-bold text-slate-900 flex items-center gap-1.5">
                            {farmer.userId?.name}
                            {farmer.verificationStatus === 'VERIFIED' && (
                              <Shield className="w-3.5 h-3.5 text-emerald-600 fill-emerald-100" />
                            )}
                          </p>
                          <p className="text-xs text-slate-500 flex items-center gap-1 mt-0.5">
                            <Phone className="w-3 h-3" /> {farmer.userId?.phone}
                          </p>
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4">
                      <p className="text-xs font-semibold text-slate-800">{farmer.village}, {farmer.district}</p>
                      <p className="text-[11px] text-slate-500 truncate max-w-[200px]">{farmer.farmAddress}</p>
                    </td>
                    <td className="px-6 py-4">
                      <span className={`inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-xs font-bold ${
                        farmer.verificationStatus === 'VERIFIED'
                          ? 'bg-emerald-100 text-emerald-800'
                          : farmer.verificationStatus === 'PENDING'
                          ? 'bg-amber-100 text-amber-800'
                          : 'bg-rose-100 text-rose-800'
                      }`}>
                        {farmer.verificationStatus}
                      </span>
                    </td>
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-1 text-xs font-bold text-amber-600">
                        <Star className="w-3.5 h-3.5 fill-amber-400" />
                        <span>{farmer.rating || 5.0}</span>
                        <span className="text-slate-400 font-normal">({farmer.totalReviews || 0} reviews)</span>
                      </div>
                      <p className="text-xs text-slate-500 mt-0.5">
                        <strong className="text-slate-800">{farmer.completedDealsCount || 0}</strong> Completed Deals
                      </p>
                    </td>
                    <td className="px-6 py-4">
                      <span className={`inline-block px-2.5 py-0.5 rounded text-xs font-semibold ${
                        farmer.userId?.status === 'ACTIVE'
                          ? 'bg-green-50 text-green-700 border border-green-200'
                          : 'bg-red-50 text-red-700 border border-red-200'
                      }`}>
                        {farmer.userId?.status || 'ACTIVE'}
                      </span>
                    </td>
                    <td className="px-6 py-4 text-right space-x-2">
                      {farmer.verificationStatus !== 'VERIFIED' && (
                        <button
                          onClick={() => handleVerify(farmer._id)}
                          className="px-2.5 py-1.5 bg-emerald-600 text-white rounded-lg text-xs font-bold hover:bg-emerald-700 transition-colors inline-flex items-center gap-1"
                        >
                          <Check className="w-3 h-3" /> Verify
                        </button>
                      )}
                      {farmer.verificationStatus === 'PENDING' && (
                        <button
                          onClick={() => handleReject(farmer._id)}
                          className="px-2.5 py-1.5 bg-rose-50 text-rose-700 border border-rose-200 rounded-lg text-xs font-bold hover:bg-rose-100 transition-colors inline-flex items-center gap-1"
                        >
                          <X className="w-3 h-3" /> Reject
                        </button>
                      )}
                      <button
                        onClick={() => handleToggleStatus(farmer.userId?._id, farmer.userId?.status)}
                        className={`px-2.5 py-1.5 rounded-lg text-xs font-bold border transition-colors inline-flex items-center gap-1 ${
                          farmer.userId?.status === 'ACTIVE'
                            ? 'bg-slate-100 text-slate-700 hover:bg-rose-50 hover:text-rose-700 border-slate-200'
                            : 'bg-emerald-50 text-emerald-700 hover:bg-emerald-100 border-emerald-200'
                        }`}
                      >
                        <Ban className="w-3 h-3" />
                        {farmer.userId?.status === 'ACTIVE' ? 'Suspend' : 'Restore'}
                      </button>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};
