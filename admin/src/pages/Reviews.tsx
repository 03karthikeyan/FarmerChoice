import React, { useEffect, useState } from 'react';
import { api } from '../services/api';
import { Review } from '../types';
import { Star, ShieldCheck, EyeOff, Check, Flag, RefreshCw } from 'lucide-react';

export const Reviews: React.FC = () => {
  const [reviews, setReviews] = useState<Review[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchReviews();
  }, []);

  const fetchReviews = async () => {
    setLoading(true);
    try {
      const res = await api.get('/admin/reviews');
      if (res.data?.success) {
        setReviews(res.data.data);
      }
    } catch (err) {
      console.warn('Fallback loading reviews:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleModerate = async (reviewId: string, status: string) => {
    try {
      await api.patch(`/admin/reviews/${reviewId}/status`, { status });
      fetchReviews();
    } catch (err: any) {
      alert(err.response?.data?.message || 'Failed to update review status');
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
        <div>
          <h3 className="text-xl font-bold text-slate-900">Verified Reviews Audit</h3>
          <p className="text-sm text-slate-500">
            Reviews are strictly validated by backend to require a completed direct deal. Audit feedback and flag fake submissions.
          </p>
        </div>
        <button
          onClick={fetchReviews}
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
                <th className="px-6 py-4">Farmer</th>
                <th className="px-6 py-4">Customer</th>
                <th className="px-6 py-4">Rating & Review</th>
                <th className="px-6 py-4">Deal Verified</th>
                <th className="px-6 py-4">Status</th>
                <th className="px-6 py-4 text-right">Moderation</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100 text-slate-700">
              {reviews.length === 0 ? (
                <tr>
                  <td colSpan={6} className="px-6 py-12 text-center text-slate-400">
                    No verified reviews recorded yet.
                  </td>
                </tr>
              ) : (
                reviews.map((r) => (
                  <tr key={r._id} className="hover:bg-slate-50/80 transition-colors">
                    <td className="px-6 py-4 text-xs font-bold text-slate-800">
                      {r.farmerId?.name}
                    </td>
                    <td className="px-6 py-4 text-xs font-semibold text-slate-700">
                      {r.customerId?.name}
                    </td>
                    <td className="px-6 py-4 max-w-sm">
                      <div className="flex items-center gap-1 text-amber-500 mb-1">
                        {[...Array(5)].map((_, i) => (
                          <Star
                            key={i}
                            className={`w-3.5 h-3.5 ${i < r.rating ? 'fill-amber-400 text-amber-400' : 'text-slate-200'}`}
                          />
                        ))}
                      </div>
                      <p className="text-xs text-slate-800 italic font-medium">"{r.comment}"</p>
                      {r.vegetableId && (
                        <p className="text-[11px] text-slate-400 mt-1">Item: {r.vegetableId.name}</p>
                      )}
                    </td>
                    <td className="px-6 py-4">
                      <span className="inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-xs font-bold bg-emerald-100 text-emerald-800 border border-emerald-200">
                        <ShieldCheck className="w-3.5 h-3.5" />
                        Deal #{r.dealId?.dealNumber || 'COMPLETED'}
                      </span>
                    </td>
                    <td className="px-6 py-4">
                      <span className={`inline-block px-2.5 py-0.5 rounded text-xs font-bold uppercase ${
                        r.status === 'PUBLISHED' ? 'bg-emerald-50 text-emerald-700 border border-emerald-200' :
                        r.status === 'HIDDEN' ? 'bg-slate-100 text-slate-600' : 'bg-rose-50 text-rose-700 border border-rose-200'
                      }`}>
                        {r.status}
                      </span>
                    </td>
                    <td className="px-6 py-4 text-right space-x-2">
                      {r.status !== 'PUBLISHED' && (
                        <button
                          onClick={() => handleModerate(r._id, 'PUBLISHED')}
                          className="px-2.5 py-1 bg-emerald-600 text-white rounded-lg text-xs font-bold hover:bg-emerald-700"
                        >
                          Publish
                        </button>
                      )}
                      {r.status === 'PUBLISHED' && (
                        <button
                          onClick={() => handleModerate(r._id, 'HIDDEN')}
                          className="px-2.5 py-1 bg-slate-100 text-slate-700 rounded-lg text-xs font-bold hover:bg-slate-200"
                        >
                          Hide
                        </button>
                      )}
                      {r.status !== 'FLAGGED' && (
                        <button
                          onClick={() => handleModerate(r._id, 'FLAGGED')}
                          className="px-2.5 py-1 bg-rose-50 text-rose-700 border border-rose-200 rounded-lg text-xs font-bold hover:bg-rose-100"
                        >
                          Flag
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
