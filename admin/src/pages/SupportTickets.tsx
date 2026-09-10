import React, { useEffect, useState } from 'react';
import { api } from '../services/api';
import { SupportTicket } from '../types';
import { HelpCircle, CheckCircle2, Clock, MessageSquare, RefreshCw } from 'lucide-react';

export const SupportTickets: React.FC = () => {
  const [tickets, setTickets] = useState<SupportTicket[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchTickets();
  }, []);

  const fetchTickets = async () => {
    setLoading(true);
    try {
      const res = await api.get('/admin/support');
      if (res.data?.success) {
        setTickets(res.data.data);
      }
    } catch (err) {
      console.warn('Fallback loading support tickets:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleUpdate = async (ticketId: string, status: string) => {
    const notes = prompt('Enter admin response or notes:');
    try {
      await api.patch(`/admin/support/${ticketId}`, { status, adminNotes: notes || 'Resolved by support team' });
      fetchTickets();
    } catch (err: any) {
      alert(err.response?.data?.message || 'Failed to update ticket');
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
        <div>
          <h3 className="text-xl font-bold text-slate-900">Support Ticket Center</h3>
          <p className="text-sm text-slate-500">Address farmer and customer help inquiries, app questions, and account assistance.</p>
        </div>
        <button
          onClick={fetchTickets}
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
                <th className="px-6 py-4">Ticket #</th>
                <th className="px-6 py-4">User</th>
                <th className="px-6 py-4">Category</th>
                <th className="px-6 py-4">Subject & Details</th>
                <th className="px-6 py-4">Status</th>
                <th className="px-6 py-4 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100 text-slate-700">
              {tickets.length === 0 ? (
                <tr>
                  <td colSpan={6} className="px-6 py-12 text-center text-slate-400">
                    No support tickets found.
                  </td>
                </tr>
              ) : (
                tickets.map((t) => (
                  <tr key={t._id} className="hover:bg-slate-50/80 transition-colors">
                    <td className="px-6 py-4 font-mono font-bold text-xs text-slate-900">
                      {t.ticketNumber}
                    </td>
                    <td className="px-6 py-4 text-xs font-semibold text-slate-800">
                      {t.userId?.name} ({t.userId?.role})
                    </td>
                    <td className="px-6 py-4 text-xs text-slate-600">
                      <span className="px-2 py-0.5 rounded bg-slate-100 font-medium">
                        {t.category}
                      </span>
                    </td>
                    <td className="px-6 py-4 max-w-sm">
                      <p className="font-bold text-slate-900 text-xs">{t.subject}</p>
                      <p className="text-xs text-slate-500 mt-0.5 line-clamp-2">{t.description}</p>
                      {t.adminNotes && (
                        <p className="text-[11px] text-emerald-700 bg-emerald-50 p-1 rounded mt-1">Admin: {t.adminNotes}</p>
                      )}
                    </td>
                    <td className="px-6 py-4">
                      <span className={`inline-block px-2.5 py-0.5 rounded text-xs font-bold uppercase ${
                        t.status === 'OPEN' ? 'bg-amber-100 text-amber-800' :
                        t.status === 'IN_PROGRESS' ? 'bg-blue-100 text-blue-800' : 'bg-emerald-100 text-emerald-800'
                      }`}>
                        {t.status}
                      </span>
                    </td>
                    <td className="px-6 py-4 text-right space-x-2">
                      {t.status !== 'RESOLVED' && (
                        <button
                          onClick={() => handleUpdate(t._id, 'RESOLVED')}
                          className="px-2.5 py-1 bg-emerald-600 text-white rounded-lg text-xs font-bold hover:bg-emerald-700"
                        >
                          Resolve
                        </button>
                      )}
                      {t.status === 'OPEN' && (
                        <button
                          onClick={() => handleUpdate(t._id, 'IN_PROGRESS')}
                          className="px-2.5 py-1 bg-blue-50 text-blue-700 border border-blue-200 rounded-lg text-xs font-bold hover:bg-blue-100"
                        >
                          In Progress
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
