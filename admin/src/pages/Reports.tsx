import React, { useEffect, useState } from 'react';
import { api } from '../services/api';
import { Report } from '../types';
import { AlertTriangle, ShieldAlert, CheckCircle2, XCircle, RefreshCw } from 'lucide-react';

export const Reports: React.FC = () => {
  const [reports, setReports] = useState<Report[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchReports();
  }, []);

  const fetchReports = async () => {
    setLoading(true);
    try {
      const res = await api.get('/admin/reports');
      if (res.data?.success) {
        setReports(res.data.data);
      }
    } catch (err) {
      console.warn('Fallback loading reports:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleResolve = async (reportId: string, status: string) => {
    const actionTaken = prompt('Enter resolution summary / action taken:');
    if (!actionTaken) return;
    try {
      await api.patch(`/admin/reports/${reportId}/resolve`, { status, actionTaken });
      fetchReports();
    } catch (err: any) {
      alert(err.response?.data?.message || 'Failed to update report');
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
        <div>
          <h3 className="text-xl font-bold text-slate-900">Safety & Moderation Reports</h3>
          <p className="text-sm text-slate-500">Investigate user reports regarding fake profiles, wrong pricing, scams or abuse.</p>
        </div>
        <button
          onClick={fetchReports}
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
                <th className="px-6 py-4">Reporter</th>
                <th className="px-6 py-4">Target Type</th>
                <th className="px-6 py-4">Reason & Description</th>
                <th className="px-6 py-4">Status</th>
                <th className="px-6 py-4">Action Taken</th>
                <th className="px-6 py-4 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100 text-slate-700">
              {reports.length === 0 ? (
                <tr>
                  <td colSpan={6} className="px-6 py-12 text-center text-slate-400">
                    No safety reports reported. Marketplace is safe!
                  </td>
                </tr>
              ) : (
                reports.map((rep) => (
                  <tr key={rep._id} className="hover:bg-slate-50/80 transition-colors">
                    <td className="px-6 py-4 text-xs font-bold text-slate-800">
                      {rep.reporterId?.name || 'User'} ({rep.reporterId?.role})
                    </td>
                    <td className="px-6 py-4 text-xs font-semibold text-slate-700">
                      <span className="px-2 py-0.5 rounded bg-slate-100 text-slate-600 uppercase font-mono">
                        {rep.targetType}
                      </span>
                    </td>
                    <td className="px-6 py-4 max-w-xs">
                      <p className="font-bold text-rose-700 text-xs">{rep.reason}</p>
                      <p className="text-xs text-slate-600 mt-0.5">{rep.description}</p>
                    </td>
                    <td className="px-6 py-4">
                      <span className={`inline-block px-2.5 py-0.5 rounded text-xs font-bold uppercase ${
                        rep.status === 'PENDING' ? 'bg-amber-100 text-amber-800 animate-pulse' :
                        rep.status === 'ACTIONED' ? 'bg-emerald-100 text-emerald-800' : 'bg-slate-100 text-slate-600'
                      }`}>
                        {rep.status}
                      </span>
                    </td>
                    <td className="px-6 py-4 text-xs text-slate-600">
                      {rep.actionTaken || 'None yet'}
                    </td>
                    <td className="px-6 py-4 text-right space-x-2">
                      {rep.status === 'PENDING' && (
                        <>
                          <button
                            onClick={() => handleResolve(rep._id, 'ACTIONED')}
                            className="px-2.5 py-1 bg-emerald-600 text-white rounded-lg text-xs font-bold hover:bg-emerald-700"
                          >
                            Action
                          </button>
                          <button
                            onClick={() => handleResolve(rep._id, 'DISMISSED')}
                            className="px-2.5 py-1 bg-slate-100 text-slate-700 rounded-lg text-xs font-bold hover:bg-slate-200"
                          >
                            Dismiss
                          </button>
                        </>
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
