import React, { useEffect, useState } from 'react';
import { api } from '../services/api';
import { Deal } from '../types';
import { Handshake, ShieldAlert, CheckCircle2, Clock, XCircle, RefreshCw } from 'lucide-react';

export const Deals: React.FC = () => {
  const [deals, setDeals] = useState<Deal[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchDeals();
  }, []);

  const fetchDeals = async () => {
    setLoading(true);
    try {
      const res = await api.get('/admin/deals');
      if (res.data?.success) {
        setDeals(res.data.data);
      }
    } catch (err) {
      console.warn('Fallback loading deals:', err);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
        <div>
          <h3 className="text-xl font-bold text-slate-900">Direct Deals Oversight</h3>
          <p className="text-sm text-slate-500">Monitor customer and farmer negotiations. Payments are settled directly without intermediary fees.</p>
        </div>
        <button
          onClick={fetchDeals}
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
                <th className="px-6 py-4">Deal ID</th>
                <th className="px-6 py-4">Vegetable & Quantity</th>
                <th className="px-6 py-4">Farmer</th>
                <th className="px-6 py-4">Customer</th>
                <th className="px-6 py-4">Ref. Value</th>
                <th className="px-6 py-4">Status</th>
                <th className="px-6 py-4">Confirmations</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100 text-slate-700">
              {deals.length === 0 ? (
                <tr>
                  <td colSpan={7} className="px-6 py-12 text-center text-slate-400">
                    No deal negotiations found.
                  </td>
                </tr>
              ) : (
                deals.map((deal) => (
                  <tr key={deal._id} className="hover:bg-slate-50/80 transition-colors">
                    <td className="px-6 py-4 font-mono font-bold text-xs text-slate-900">
                      {deal.dealNumber}
                    </td>
                    <td className="px-6 py-4">
                      <p className="font-bold text-slate-900">{deal.vegetableId?.name || 'Vegetable'}</p>
                      <p className="text-xs text-slate-500">
                        {deal.agreedQuantity || deal.requestedQuantity} {deal.priceUnit} @ ₹{deal.agreedPrice || deal.requestedPrice}/{deal.priceUnit}
                      </p>
                    </td>
                    <td className="px-6 py-4 text-xs font-semibold text-slate-800">
                      {deal.farmerId?.name}
                    </td>
                    <td className="px-6 py-4 text-xs font-semibold text-slate-800">
                      {deal.customerId?.name}
                    </td>
                    <td className="px-6 py-4 font-bold text-slate-900">
                      ₹{deal.dealReferenceValue}
                    </td>
                    <td className="px-6 py-4">
                      <span className={`inline-block px-2.5 py-0.5 rounded text-xs font-bold uppercase ${
                        deal.status === 'COMPLETED' ? 'bg-emerald-100 text-emerald-800' :
                        deal.status === 'ACCEPTED' ? 'bg-blue-100 text-blue-800' :
                        deal.status === 'CANCELLED' ? 'bg-rose-100 text-rose-800' : 'bg-amber-100 text-amber-800'
                      }`}>
                        {deal.status}
                      </span>
                    </td>
                    <td className="px-6 py-4 text-xs space-y-1">
                      <div className="flex items-center gap-1">
                        <span className={`w-2 h-2 rounded-full ${deal.customerConfirmed ? 'bg-emerald-500' : 'bg-slate-300'}`}></span>
                        <span>Customer: {deal.customerConfirmed ? 'Confirmed' : 'Pending'}</span>
                      </div>
                      <div className="flex items-center gap-1">
                        <span className={`w-2 h-2 rounded-full ${deal.farmerConfirmed ? 'bg-emerald-500' : 'bg-slate-300'}`}></span>
                        <span>Farmer: {deal.farmerConfirmed ? 'Confirmed' : 'Pending'}</span>
                      </div>
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
