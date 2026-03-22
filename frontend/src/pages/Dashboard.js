import React, { useEffect, useState } from 'react';
import {
  PieChart,
  Pie,
  Cell,
  Tooltip,
  ResponsiveContainer,
} from 'recharts';
import { getCampaigns, getAuditors, getTradeshops, getAuditResponses } from '../services/api';
import './shared.css';
import './Dashboard.css';

const PIE_COLORS = ['#27ae60', '#f39c12', '#7a8ca0'];

const Dashboard = () => {
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [stats, setStats] = useState({
    campaigns: 0,
    auditors: 0,
    tradeshops: 0,
    audits: 0,
  });
  const [campaigns, setCampaigns] = useState([]);
  const [recentAudits, setRecentAudits] = useState([]);

  useEffect(() => {
    const loadData = async () => {
      try {
        setLoading(true);
        const [campaignData, auditorData, tradeshopData, responseData] = await Promise.all([
          getCampaigns(),
          getAuditors(),
          getTradeshops(),
          getAuditResponses({ limit: 5 }),
        ]);

        setStats({
          campaigns: campaignData.length,
          auditors: auditorData.length,
          tradeshops: tradeshopData.length,
          audits: responseData.length,
        });
        setCampaigns(campaignData.slice(0, 4));
        setRecentAudits(responseData.slice(0, 5));
      } catch (err) {
        setError('Хянах самбарын мэдээлэл ачаалж чадсангүй.');
      } finally {
        setLoading(false);
      }
    };

    loadData();
  }, []);

  const overviewData = [
    { name: 'Идэвхтэй', value: campaigns.filter((item) => item.is_active).length },
    { name: 'Хүлээгдэж буй', value: campaigns.filter((item) => item.progress_percent < 100 && item.is_active).length },
    { name: 'Дууссан', value: campaigns.filter((item) => item.progress_percent >= 100).length },
  ].filter((item) => item.value > 0);

  if (loading) {
    return (
      <div className="loading-container">
        <div className="loading-spinner" />
        <p>Хянах самбар ачааллаж байна...</p>
      </div>
    );
  }

  return (
    <div className="page-container dashboard-page">
      {error && <div className="error-message">{error}</div>}

      <section className="metric-grid">
        <div className="metric-card">
          <div className="metric-copy">
            <span className="metric-value">{stats.campaigns}</span>
            <span className="metric-label">Кампанит ажил</span>
          </div>
          <span className="metric-icon blue" />
        </div>
        <div className="metric-card">
          <div className="metric-copy">
            <span className="metric-value">{stats.auditors}</span>
            <span className="metric-label">Аудиторууд</span>
          </div>
          <span className="metric-icon green" />
        </div>
        <div className="metric-card">
          <div className="metric-copy">
            <span className="metric-value">{stats.tradeshops}</span>
            <span className="metric-label">Дэлгүүрүүд</span>
          </div>
          <span className="metric-icon orange" />
        </div>
        <div className="metric-card">
          <div className="metric-copy">
            <span className="metric-value">{stats.audits}</span>
            <span className="metric-label">Гүйцэтгэсэн аудит</span>
          </div>
          <span className="metric-icon red" />
        </div>
      </section>

      <section className="dashboard-split">
        <div className="content-card">
          <div className="dashboard-card-header">
            <h3>Идэвхтэй кампанит ажлууд</h3>
          </div>
          {campaigns.length === 0 ? (
            <div className="empty-state compact">
              <p>Кампанит ажил алга байна.</p>
            </div>
          ) : (
            <div className="progress-list">
              {campaigns.map((campaign) => (
                <div key={campaign.id} className="progress-item">
                  <div className="progress-item-top">
                    <span className="table-title">{campaign.name}</span>
                    <span className="table-meta">{campaign.progress_percent}%</span>
                  </div>
                  <div className="progress-track">
                    <div className="progress-fill" style={{ width: `${campaign.progress_percent}%` }} />
                  </div>
                  <span className="table-meta">
                    {campaign.completed_audits} / {campaign.total_tradeshops} дэлгүүр
                  </span>
                </div>
              ))}
            </div>
          )}
        </div>

        <div className="content-card">
          <div className="dashboard-card-header">
            <h3>Системийн тойм</h3>
          </div>
          {overviewData.length === 0 ? (
            <div className="empty-state compact">
              <p>Тойм харуулах мэдээлэл алга байна.</p>
            </div>
          ) : (
            <div className="chart-wrap">
              <ResponsiveContainer width="100%" height={220}>
                <PieChart>
                  <Pie data={overviewData} dataKey="value" innerRadius={58} outerRadius={84} paddingAngle={5}>
                    {overviewData.map((item, index) => (
                      <Cell key={item.name} fill={PIE_COLORS[index % PIE_COLORS.length]} />
                    ))}
                  </Pie>
                  <Tooltip />
                </PieChart>
              </ResponsiveContainer>
              <div className="chart-legend">
                {overviewData.map((item, index) => (
                  <div key={item.name} className="legend-item">
                    <span className="legend-color" style={{ background: PIE_COLORS[index % PIE_COLORS.length] }} />
                    <span>{item.name}</span>
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>
      </section>

      <section className="content-card">
        <div className="dashboard-card-header">
          <h3>Сүүлийн аудит илгээлтүүд</h3>
        </div>
        <div className="data-table-scroll">
          <table className="data-table">
            <thead>
              <tr>
                <th>Дэлгүүр</th>
                <th>Кампанит ажил</th>
                <th>Аудитор</th>
                <th>Төлөв</th>
                <th>Огноо</th>
              </tr>
            </thead>
            <tbody>
              {recentAudits.length === 0 ? (
                <tr>
                  <td colSpan="5">
                    <div className="empty-state compact">
                      <p>Сүүлийн аудит илгээлт алга байна.</p>
                    </div>
                  </td>
                </tr>
              ) : (
                recentAudits.map((audit) => (
                  <tr key={audit.id}>
                    <td>{audit.tradeshop_name || '-'}</td>
                    <td>{audit.campaign_name || '-'}</td>
                    <td>{audit.auditor_name || '-'}</td>
                    <td>
                      <span className={`badge ${audit.status === 'completed' ? 'badge-active' : 'badge-warning'}`}>
                        {audit.status === 'completed' ? 'Амжилттай' : 'Хүлээгдэж буй'}
                      </span>
                    </td>
                    <td>{new Date(audit.submitted_at).toLocaleDateString()}</td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </section>
    </div>
  );
};

export default Dashboard;
