import React, { useEffect, useState } from 'react';
import { api } from '../services/api';
import { Vegetable } from '../types';
import { ShoppingBag, Sparkles, Check, X, Eye, RefreshCw, Filter } from 'lucide-react';

export const Vegetables: React.FC = () => {
  const [vegetables, setVegetables] = useState<Vegetable[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedCategory, setSelectedCategory] = useState('All');

  useEffect(() => {
    fetchVegetables();
  }, [selectedCategory]);

  const fetchVegetables = async () => {
    setLoading(true);
    try {
      const url = selectedCategory === 'All' ? '/admin/vegetables' : `/admin/vegetables?category=${selectedCategory}`;
      const res = await api.get(url);
      if (res.data?.success) {
        setVegetables(res.data.data);
      }
    } catch (err) {
      console.warn('Fallback loading vegetables:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleModerateFeatured = async (vegId: string, approve: boolean) => {
    try {
      await api.patch(`/admin/vegetables/${vegId}/featured`, { approve, durationDays: 14 });
      fetchVegetables();
    } catch (err: any) {
      alert(err.response?.data?.message || 'Failed to update featured status');
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
        <div>
          <h3 className="text-xl font-bold text-slate-900">Vegetable Listings & Featured Requests</h3>
          <p className="text-sm text-slate-500">Monitor farmer vegetable listings, pricing, and approve homepage featured slots.</p>
        </div>
        <div className="flex items-center gap-3">
          <select
            value={selectedCategory}
            onChange={(e) => setSelectedCategory(e.target.value)}
            className="px-3 py-2 bg-white border border-slate-200 rounded-xl text-xs font-semibold text-slate-700 shadow-sm outline-none"
          >
            <option value="All">All Categories</option>
            <option value="Vegetable">Vegetable</option>
            <option value="Leafy">Leafy</option>
            <option value="Root">Root</option>
            <option value="Other">Other</option>
          </select>
          <button
            onClick={fetchVegetables}
            className="flex items-center gap-2 px-4 py-2 bg-white border border-slate-200 rounded-xl text-xs font-semibold text-slate-700 hover:bg-slate-50 shadow-sm"
          >
            <RefreshCw className="w-3.5 h-3.5" /> Refresh
          </button>
        </div>
      </div>

      <div className="bg-white rounded-2xl border border-slate-200 overflow-hidden shadow-sm">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-sm">
            <thead className="bg-slate-50 text-slate-500 text-xs uppercase tracking-wider border-b border-slate-200">
              <tr>
                <th className="px-6 py-4">Vegetable</th>
                <th className="px-6 py-4">Farmer / Farm</th>
                <th className="px-6 py-4">Price / Unit</th>
                <th className="px-6 py-4">Available Qty</th>
                <th className="px-6 py-4">Featured Status</th>
                <th className="px-6 py-4 text-right">Moderation</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100 text-slate-700">
              {vegetables.length === 0 ? (
                <tr>
                  <td colSpan={6} className="px-6 py-12 text-center text-slate-400">
                    No vegetables found.
                  </td>
                </tr>
              ) : (
                vegetables.map((v) => (
                  <tr key={v._id} className="hover:bg-slate-50/80 transition-colors">
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-3">
                        <img
                          src={v.images?.[0] || 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=100'}
                          alt=""
                          className="w-12 h-12 rounded-xl object-cover border border-slate-200 shrink-0"
                        />
                        <div>
                          <p className="font-bold text-slate-900">{v.name}</p>
                          {v.tamilName && <p className="text-xs text-emerald-700 font-medium">{v.tamilName}</p>}
                          <span className="inline-block px-2 py-0.5 rounded text-[10px] font-semibold bg-slate-100 text-slate-600 mt-1">
                            {v.category}
                          </span>
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4">
                      <p className="text-xs font-bold text-slate-800">{v.farmerId?.name}</p>
                      <p className="text-[11px] text-slate-500">{v.farmerProfileId?.village}, {v.farmerProfileId?.district}</p>
                    </td>
                    <td className="px-6 py-4">
                      <p className="text-sm font-extrabold text-emerald-700">₹{v.price} <span className="text-xs font-normal text-slate-500">/ {v.priceUnit}</span></p>
                    </td>
                    <td className="px-6 py-4">
                      <p className="text-xs font-bold text-slate-800">{v.availableQuantity} {v.priceUnit}</p>
                      <span className={`inline-block px-2 py-0.5 rounded text-[10px] font-bold ${
                        v.availabilityStatus === 'AVAILABLE_NOW' ? 'bg-emerald-100 text-emerald-800' : 'bg-amber-100 text-amber-800'
                      }`}>
                        {v.availabilityStatus}
                      </span>
                    </td>
                    <td className="px-6 py-4">
                      <span className={`inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-xs font-bold ${
                        v.featuredStatus === 'APPROVED'
                          ? 'bg-amber-100 text-amber-800 border border-amber-200'
                          : v.featuredStatus === 'REQUESTED'
                          ? 'bg-purple-100 text-purple-800 animate-pulse'
                          : 'bg-slate-100 text-slate-600'
                      }`}>
                        <Sparkles className="w-3 h-3" />
                        {v.featuredStatus}
                      </span>
                    </td>
                    <td className="px-6 py-4 text-right space-x-2">
                      {v.featuredStatus === 'REQUESTED' ? (
                        <>
                          <button
                            onClick={() => handleModerateFeatured(v._id, true)}
                            className="px-2.5 py-1 bg-emerald-600 text-white rounded-lg text-xs font-bold hover:bg-emerald-700"
                          >
                            Approve
                          </button>
                          <button
                            onClick={() => handleModerateFeatured(v._id, false)}
                            className="px-2.5 py-1 bg-rose-50 text-rose-700 border border-rose-200 rounded-lg text-xs font-bold hover:bg-rose-100"
                          >
                            Reject
                          </button>
                        </>
                      ) : (
                        <button
                          onClick={() => handleModerateFeatured(v._id, v.featuredStatus !== 'APPROVED')}
                          className={`px-2.5 py-1 rounded-lg text-xs font-bold border transition-colors ${
                            v.featuredStatus === 'APPROVED'
                              ? 'bg-amber-50 text-amber-800 border-amber-200 hover:bg-amber-100'
                              : 'bg-slate-50 text-slate-700 border-slate-200 hover:bg-slate-100'
                          }`}
                        >
                          {v.featuredStatus === 'APPROVED' ? 'Remove Featured' : 'Make Featured'}
                        </button>
                      )}
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
