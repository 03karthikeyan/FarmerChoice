import React from 'react';
import { BarChart3, TrendingUp, Users, ShoppingBag, Handshake, Star } from 'lucide-react';

export const Analytics: React.FC = () => {
  return (
    <div className="space-y-6">
      <div>
        <h3 className="text-xl font-bold text-slate-900">Platform Activity Analytics</h3>
        <p className="text-sm text-slate-500">Insights into farmer registrations, vegetable demand, deal completions, and customer growth.</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm space-y-4">
          <div className="flex items-center justify-between">
            <h4 className="font-bold text-slate-800 text-sm">Most In-Demand Vegetables</h4>
            <ShoppingBag className="w-5 h-5 text-emerald-600" />
          </div>
          <div className="space-y-3">
            {[
              { name: 'Fresh Tomato', requests: 48, pct: '85%' },
              { name: 'Small Onion / Shallots', requests: 36, pct: '70%' },
              { name: 'Palak Keerai', requests: 29, pct: '55%' },
              { name: 'Ladies Finger', requests: 22, pct: '40%' },
              { name: 'Fresh Carrot', requests: 18, pct: '30%' }
            ].map((item, i) => (
              <div key={i} className="space-y-1">
                <div className="flex justify-between text-xs font-semibold">
                  <span className="text-slate-800">{item.name}</span>
                  <span className="text-emerald-700">{item.requests} deals</span>
                </div>
                <div className="w-full bg-slate-100 h-2 rounded-full overflow-hidden">
                  <div className="bg-emerald-600 h-full rounded-full" style={{ width: item.pct }}></div>
                </div>
              </div>
            ))}
          </div>
        </div>

        <div className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm space-y-4">
          <div className="flex items-center justify-between">
            <h4 className="font-bold text-slate-800 text-sm">Deal Status Distribution</h4>
            <Handshake className="w-5 h-5 text-purple-600" />
          </div>
          <div className="space-y-3">
            {[
              { status: 'Completed', count: 89, color: 'bg-emerald-500' },
              { status: 'Accepted / Ready', count: 24, color: 'bg-blue-500' },
              { status: 'Negotiating', count: 12, color: 'bg-amber-500' },
              { status: 'Requested', count: 8, color: 'bg-purple-500' },
              { status: 'Cancelled', count: 3, color: 'bg-rose-400' }
            ].map((s, i) => (
              <div key={i} className="flex items-center justify-between text-xs py-1.5 border-b border-slate-100">
                <div className="flex items-center gap-2">
                  <span className={`w-2.5 h-2.5 rounded-full ${s.color}`}></span>
                  <span className="font-medium text-slate-700">{s.status}</span>
                </div>
                <span className="font-bold text-slate-900">{s.count}</span>
              </div>
            ))}
          </div>
        </div>

        <div className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm space-y-4">
          <div className="flex items-center justify-between">
            <h4 className="font-bold text-slate-800 text-sm">Top Tamil Nadu Agricultural Districts</h4>
            <Users className="w-5 h-5 text-blue-600" />
          </div>
          <div className="space-y-3">
            {[
              { district: 'Thanjavur (Cauvery Delta)', farmers: 18, share: '45%' },
              { district: 'Madurai', farmers: 12, share: '25%' },
              { district: 'Coimbatore', farmers: 9, share: '18%' },
              { district: 'Salem', farmers: 6, share: '12%' }
            ].map((d, i) => (
              <div key={i} className="flex items-center justify-between text-xs py-1.5 border-b border-slate-100">
                <span className="font-medium text-slate-700">{d.district}</span>
                <span className="font-bold text-emerald-700">{d.farmers} farmers</span>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
};
