import React, { useEffect, useState } from 'react';
import { api } from '../services/api';
import { CustomerProfile } from '../types';
import { Users, Phone, MapPin, Ban, RefreshCw } from 'lucide-react';

export const Customers: React.FC = () => {
  const [customers, setCustomers] = useState<CustomerProfile[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchCustomers();
  }, []);

  const fetchCustomers = async () => {
    setLoading(true);
    try {
      const res = await api.get('/admin/customers');
      if (res.data?.success) {
        setCustomers(res.data.data);
      }
    } catch (err) {
      console.warn('Fallback loading customers:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleToggleStatus = async (userId: string, currentStatus: string) => {
    const newStatus = currentStatus === 'ACTIVE' ? 'SUSPENDED' : 'ACTIVE';
    try {
      await api.patch(`/admin/users/${userId}/status`, { status: newStatus });
      fetchCustomers();
    } catch (err: any) {
      alert(err.response?.data?.message || 'Failed to update user status');
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
        <div>
          <h3 className="text-xl font-bold text-slate-900">Customer Directory</h3>
          <p className="text-sm text-slate-500">View registered customers connecting with direct farmers.</p>
        </div>
        <button
          onClick={fetchCustomers}
          className="flex items-center gap-2 px-4 py-2 bg-white border border-slate-200 rounded-xl text-xs font-semibold text-slate-700 hover:bg-slate-50 shadow-sm"
        >
          <RefreshCw className="w-3.5 h-3.5" /> Refresh
        </button>
      </div>

      <div className="bg-white rounded-2xl border border-slate-200 overflow-hidden shadow-sm">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-sm">
            <thead className="bg-slate-50 text-slate-500 text-xs uppercase tracking-wider border-b border-slate-200">
              <tr>
                <th className="px-6 py-4">Customer</th>
                <th className="px-6 py-4">Location</th>
                <th className="px-6 py-4">Delivery Address</th>
                <th className="px-6 py-4">Account Status</th>
                <th className="px-6 py-4 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100 text-slate-700">
              {customers.length === 0 ? (
                <tr>
                  <td colSpan={5} className="px-6 py-12 text-center text-slate-400">
                    No customers found.
                  </td>
                </tr>
              ) : (
                customers.map((c) => (
                  <tr key={c._id} className="hover:bg-slate-50/80 transition-colors">
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-3">
                        <img
                          src={c.userId?.profileImage || 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100'}
                          alt=""
                          className="w-10 h-10 rounded-full object-cover border border-slate-200 shrink-0"
                        />
                        <div>
                          <p className="font-bold text-slate-900">{c.userId?.name}</p>
                          <p className="text-xs text-slate-500 flex items-center gap-1 mt-0.5">
                            <Phone className="w-3 h-3" /> {c.userId?.phone}
                          </p>
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4">
                      <p className="text-xs font-semibold text-slate-800">{c.villageOrTown}, {c.district}</p>
                      <p className="text-[11px] text-slate-500">{c.state}</p>
                    </td>
                    <td className="px-6 py-4 text-xs text-slate-600 max-w-[250px] truncate">
                      {c.defaultDeliveryAddress || 'Not set'}
                    </td>
                    <td className="px-6 py-4">
                      <span className={`inline-block px-2.5 py-0.5 rounded text-xs font-semibold ${
                        c.userId?.status === 'ACTIVE'
                          ? 'bg-green-50 text-green-700 border border-green-200'
                          : 'bg-red-50 text-red-700 border border-red-200'
                      }`}>
                        {c.userId?.status || 'ACTIVE'}
                      </span>
                    </td>
                    <td className="px-6 py-4 text-right">
                      <button
                        onClick={() => handleToggleStatus(c.userId?._id, c.userId?.status)}
                        className={`px-3 py-1.5 rounded-lg text-xs font-bold border transition-colors inline-flex items-center gap-1 ${
                          c.userId?.status === 'ACTIVE'
                            ? 'bg-slate-100 text-slate-700 hover:bg-rose-50 hover:text-rose-700 border-slate-200'
                            : 'bg-emerald-50 text-emerald-700 hover:bg-emerald-100 border-emerald-200'
                        }`}
                      >
                        <Ban className="w-3 h-3" />
                        {c.userId?.status === 'ACTIVE' ? 'Suspend' : 'Restore'}
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
