import React, { useEffect, useMemo, useState } from 'react';
import {
  getAuditResponse,
  getAuditResponses,
  getAuditors,
  getCampaigns,
  getTradeshops,
} from '../services/api';
import './shared.css';
import './AuditResults.css';

const AuditResults = () => {
  const [responses, setResponses] = useState([]);
  const [campaigns, setCampaigns] = useState([]);
  const [tradeshops, setTradeshops] = useState([]);
  const [auditors, setAuditors] = useState([]);
  const [selectedResponse, setSelectedResponse] = useState(null);
  const [showModal, setShowModal] = useState(false);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [filters, setFilters] = useState({
    campaign_id: '',
    tradeshop_id: '',
    auditor_id: '',
    date_from: '',
    date_to: '',
    search: '',
  });

  const loadData = async () => {
    try {
      setLoading(true);
      const [responseData, campaignData, tradeshopData, auditorData] = await Promise.all([
        getAuditResponses({ limit: 100 }),
        getCampaigns(),
        getTradeshops(),
        getAuditors(),
      ]);
      setResponses(responseData);
      setCampaigns(campaignData);
      setTradeshops(tradeshopData);
      setAuditors(auditorData);
    } catch (err) {
      setError('Аудитын үр дүн ачаалж чадсангүй.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadData();
  }, []);

  const filteredResponses = useMemo(
    () =>
      responses.filter((response) => {
        if (filters.campaign_id && response.campaign_id !== filters.campaign_id) return false;
        if (filters.tradeshop_id && response.tradeshop_id !== filters.tradeshop_id) return false;
        if (filters.auditor_id && response.auditor_id !== filters.auditor_id) return false;
        if (filters.date_from && new Date(response.submitted_at) < new Date(filters.date_from)) return false;
        if (filters.date_to) {
          const toDate = new Date(filters.date_to);
          toDate.setHours(23, 59, 59, 999);
          if (new Date(response.submitted_at) > toDate) return false;
        }
        if (filters.search) {
          const query = filters.search.toLowerCase();
          const haystack = [response.tradeshop_name, response.campaign_name, response.auditor_name]
            .filter(Boolean)
            .join(' ')
            .toLowerCase();
          if (!haystack.includes(query)) return false;
        }
        return true;
      }),
    [responses, filters]
  );

  const openDetails = async (responseId) => {
    try {
      const detail = await getAuditResponse(responseId);
      setSelectedResponse(detail);
      setShowModal(true);
    } catch (err) {
      setError('Дэлгэрэнгүй мэдээлэл ачаалж чадсангүй.');
    }
  };

  return (
    <div className="page-container">
      <div className="page-header">
        <div>
          <h1>Аудитын үр дүн</h1>
          <p className="page-subtitle">Кампанит ажил, дэлгүүр, аудитор, хугацаагаар шүүж гүйцэтгэлийг шалгана.</p>
        </div>
        <div className="page-actions">
          <span className="badge badge-neutral">{filteredResponses.length}</span>
        </div>
      </div>

      {error && <div className="error-message">{error}</div>}

      <section className="filters-panel filters-stack">
        <div className="filters-bar">
          <div className="form-group">
            <label>Кампанит ажил</label>
            <select value={filters.campaign_id} onChange={(event) => setFilters({ ...filters, campaign_id: event.target.value })}>
              <option value="">Бүх кампани</option>
              {campaigns.map((campaign) => (
                <option key={campaign.id} value={campaign.id}>
                  {campaign.name}
                </option>
              ))}
            </select>
          </div>
          <div className="form-group">
            <label>Дэлгүүр</label>
            <select value={filters.tradeshop_id} onChange={(event) => setFilters({ ...filters, tradeshop_id: event.target.value })}>
              <option value="">Бүх дэлгүүр</option>
              {tradeshops.map((shop) => (
                <option key={shop.id} value={shop.id}>
                  {shop.name}
                </option>
              ))}
            </select>
          </div>
          <div className="form-group">
            <label>Аудитор</label>
            <select value={filters.auditor_id} onChange={(event) => setFilters({ ...filters, auditor_id: event.target.value })}>
              <option value="">Бүх аудитор</option>
              {auditors.map((auditor) => (
                <option key={auditor.id} value={auditor.id}>
                  {auditor.name}
                </option>
              ))}
            </select>
          </div>
        </div>

        <div className="filters-bar">
          <div className="form-group">
            <label>Эхлэх огноо</label>
            <input className="date-input" type="date" value={filters.date_from} onChange={(event) => setFilters({ ...filters, date_from: event.target.value })} />
          </div>
          <div className="form-group">
            <label>Дуусах огноо</label>
            <input className="date-input" type="date" value={filters.date_to} onChange={(event) => setFilters({ ...filters, date_to: event.target.value })} />
          </div>
          <div className="form-group">
            <label>Хайлт</label>
            <input
              className="search-input"
              type="text"
              placeholder="Дэлгүүр, кампани..."
              value={filters.search}
              onChange={(event) => setFilters({ ...filters, search: event.target.value })}
            />
          </div>
        </div>
      </section>

      <section className="data-table-container">
        <div className="data-table-scroll">
          <table className="data-table">
            <thead>
              <tr>
                <th>Огноо</th>
                <th>Кампанит ажил</th>
                <th>Дэлгүүр</th>
                <th>Аудитор</th>
                <th>Илрүүлэлт</th>
                <th>Хариулт</th>
                <th>Үйлдэл</th>
              </tr>
            </thead>
            <tbody>
              {loading ? (
                <tr>
                  <td colSpan="7" className="table-loading">Ачааллаж байна...</td>
                </tr>
              ) : filteredResponses.length === 0 ? (
                <tr>
                  <td colSpan="7">
                    <div className="empty-state compact">
                      <h3>Үр дүн олдсонгүй</h3>
                      <p>Шүүлтээ өөрчлөөд дахин оролдоно уу.</p>
                    </div>
                  </td>
                </tr>
              ) : (
                filteredResponses.map((response) => (
                  <tr key={response.id}>
                    <td>{new Date(response.submitted_at).toLocaleString()}</td>
                    <td>{response.campaign_name || '-'}</td>
                    <td>{response.tradeshop_name || '-'}</td>
                    <td>{response.auditor_name || '-'}</td>
                    <td>
                      <span className="badge badge-neutral">
                        {Object.values(response.detection_summary || {}).reduce((sum, value) => sum + value, 0)}
                      </span>
                    </td>
                    <td>
                      <span className="badge badge-neutral">{response.answers?.length || 0}</span>
                    </td>
                    <td>
                      <button className="btn btn-secondary btn-sm" type="button" onClick={() => openDetails(response.id)}>
                        Дэлгэрэнгүй
                      </button>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </section>

      {showModal && selectedResponse && (
        <div className="modal-overlay" onClick={() => setShowModal(false)}>
          <div className="modal modal-large" onClick={(event) => event.stopPropagation()}>
            <div className="modal-header">
              <h2>Аудитын дэлгэрэнгүй мэдээлэл</h2>
              <button className="modal-close" type="button" onClick={() => setShowModal(false)}>
                &times;
              </button>
            </div>

            <div className="modal-body">
              <section className="summary-grid">
                <div className="content-card detail-mini-card">
                  <span className="table-meta">Кампанит ажил</span>
                  <span className="table-title">{selectedResponse.campaign_name || '-'}</span>
                </div>
                <div className="content-card detail-mini-card">
                  <span className="table-meta">Дэлгүүр</span>
                  <span className="table-title">{selectedResponse.tradeshop_name || '-'}</span>
                </div>
                <div className="content-card detail-mini-card">
                  <span className="table-meta">Аудитор</span>
                  <span className="table-title">{selectedResponse.auditor_name || '-'}</span>
                </div>
                <div className="content-card detail-mini-card">
                  <span className="table-meta">Илгээсэн огноо</span>
                  <span className="table-title">{new Date(selectedResponse.submitted_at).toLocaleString()}</span>
                </div>
              </section>

              <section className="detail-section">
                <h3>AI Илрүүлэлтийн үр дүн</h3>
                <div className="tags-container">
                  <span className="badge badge-active">{selectedResponse.detection_total || 0} бүтээгдэхүүн илэрсэн</span>
                  <span className="badge badge-neutral">{selectedResponse.detection_processing_time_ms || 0}ms боловсруулалт</span>
                </div>
                <div className="detail-list">
                  {(selectedResponse.detection_items || []).length === 0 ? (
                    <p className="page-subtitle">Detection item алга байна.</p>
                  ) : (
                    selectedResponse.detection_items.map((item, index) => (
                      <div key={`${item.class_name}-${index}`} className="detail-row-card">
                        <div>
                          <span className="table-title">{item.class_name}</span>
                          <span className="table-meta">Confidence: {Math.round((item.confidence || 0) * 1000) / 10}%</span>
                        </div>
                        <span className="badge badge-neutral">{item.class_name}</span>
                      </div>
                    ))
                  )}
                </div>
              </section>

              <section className="detail-section">
                <h3>Судалгааны хариултууд</h3>
                <div className="detail-list">
                  {(selectedResponse.answers || []).map((answer, index) => (
                    <div key={answer.question_id} className="detail-row-card">
                      <div className="answer-copy">
                        <div className="tags-container">
                          <span className="badge badge-neutral">Q{index + 1}</span>
                          {answer.auto_answered && <span className="badge badge-admin">AI Автомат</span>}
                        </div>
                        <span className="table-title">{answer.question_text}</span>
                        <span className="table-meta">Хариулт: {Array.isArray(answer.answer) ? answer.answer.join(', ') : String(answer.answer)}</span>
                      </div>
                    </div>
                  ))}
                </div>
              </section>

              <section className="detail-section">
                <h3>Зургууд</h3>
                <div className="image-grid">
                  {(selectedResponse.photos || []).length === 0 ? (
                    <>
                      <div className="image-placeholder" />
                      <div className="image-placeholder" />
                      <div className="image-placeholder" />
                    </>
                  ) : (
                    selectedResponse.photos.map((photo) => (
                      <div key={photo} className="image-placeholder with-label">
                        <span>{photo.split('/').pop()}</span>
                      </div>
                    ))
                  )}
                </div>
              </section>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default AuditResults;
