import React, { useEffect, useState } from 'react';
import {
  createCampaign,
  deleteCampaign,
  getCampaigns,
  getSurveys,
  getTradeshops,
  updateCampaign,
} from '../services/api';
import './shared.css';

const emptyForm = {
  name: '',
  description: '',
  start_date: '',
  end_date: '',
  survey_id: '',
  target_tradeshop_ids: [],
  is_active: true,
};

const Campaigns = () => {
  const [campaigns, setCampaigns] = useState([]);
  const [surveys, setSurveys] = useState([]);
  const [tradeshops, setTradeshops] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [searchTerm, setSearchTerm] = useState('');
  const [filterStatus, setFilterStatus] = useState('');
  const [showModal, setShowModal] = useState(false);
  const [editingCampaign, setEditingCampaign] = useState(null);
  const [formData, setFormData] = useState(emptyForm);

  const loadData = async () => {
    try {
      setLoading(true);
      const [campaignData, surveyData, tradeshopData] = await Promise.all([
        getCampaigns(),
        getSurveys(),
        getTradeshops(),
      ]);
      setCampaigns(campaignData);
      setSurveys(surveyData);
      setTradeshops(tradeshopData);
    } catch (err) {
      setError('Кампанийн мэдээлэл ачаалж чадсангүй.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadData();
  }, []);

  const getStatus = (campaign) => {
    const now = new Date();
    const start = campaign.start_date ? new Date(campaign.start_date) : null;
    const end = campaign.end_date ? new Date(campaign.end_date) : null;

    if (!campaign.is_active) {
      return { label: 'Идэвхгүй', className: 'badge-inactive' };
    }
    if (start && now < start) {
      return { label: 'Хүлээгдэж буй', className: 'badge-pending' };
    }
    if (end && now > end) {
      return { label: 'Дууссан', className: 'badge-neutral' };
    }
    return { label: 'Идэвхтэй', className: 'badge-active' };
  };

  const resetModal = () => {
    setEditingCampaign(null);
    setFormData(emptyForm);
    setShowModal(false);
  };

  const handleSubmit = async (event) => {
    event.preventDefault();
    setError('');

    const payload = {
      name: formData.name,
      description: formData.description || null,
      start_date: new Date(formData.start_date).toISOString(),
      end_date: new Date(formData.end_date).toISOString(),
      survey_id: formData.survey_id || null,
      target_tradeshop_ids: formData.target_tradeshop_ids,
      is_active: formData.is_active,
    };

    try {
      if (editingCampaign) {
        await updateCampaign(editingCampaign.id, payload);
      } else {
        await createCampaign(payload);
      }
      resetModal();
      await loadData();
    } catch (err) {
      setError(err.response?.data?.detail || 'Кампанит ажил хадгалж чадсангүй.');
    }
  };

  const filteredCampaigns = campaigns.filter((campaign) => {
    const status = getStatus(campaign);
    const matchesSearch = campaign.name.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesStatus = !filterStatus || status.label === filterStatus;
    return matchesSearch && matchesStatus;
  });

  return (
    <div className="page-container">
      <div className="page-header">
        <div>
          <h1>Кампанит ажил</h1>
          <p className="page-subtitle">Судалгаа, хугацаа, зорилтот дэлгүүрийн хүрээнд аудитын кампанит ажил удирдана.</p>
        </div>
        <button className="btn btn-primary" type="button" onClick={() => { setEditingCampaign(null); setFormData(emptyForm); setShowModal(true); }}>
          Кампанит ажил нэмэх
        </button>
      </div>

      {error && <div className="error-message">{error}</div>}

      <section className="filters-panel">
        <div className="filters-bar">
          <input
            className="search-input"
            type="text"
            placeholder="Кампанит ажил хайх..."
            value={searchTerm}
            onChange={(event) => setSearchTerm(event.target.value)}
          />
          <select className="filter-select" value={filterStatus} onChange={(event) => setFilterStatus(event.target.value)}>
            <option value="">Бүх төлөв</option>
            <option value="Идэвхтэй">Идэвхтэй</option>
            <option value="Хүлээгдэж буй">Хүлээгдэж буй</option>
            <option value="Дууссан">Дууссан</option>
            <option value="Идэвхгүй">Идэвхгүй</option>
          </select>
        </div>
      </section>

      <section className="data-table-container">
        <div className="data-table-scroll">
          <table className="data-table">
            <thead>
              <tr>
                <th>Нэр</th>
                <th>Хугацаа</th>
                <th>Судалгаа</th>
                <th>Дэлгүүр</th>
                <th>Явц</th>
                <th>Төлөв</th>
                <th>Үйлдэл</th>
              </tr>
            </thead>
            <tbody>
              {loading ? (
                <tr>
                  <td colSpan="7" className="table-loading">Ачааллаж байна...</td>
                </tr>
              ) : filteredCampaigns.length === 0 ? (
                <tr>
                  <td colSpan="7">
                    <div className="empty-state compact">
                      <h3>Кампанит ажил олдсонгүй</h3>
                      <p>Шинэ кампанит ажил үүсгэж эхэлнэ үү.</p>
                    </div>
                  </td>
                </tr>
              ) : (
                filteredCampaigns.map((campaign) => {
                  const status = getStatus(campaign);
                  return (
                    <tr key={campaign.id}>
                      <td>
                        <span className="table-title">{campaign.name}</span>
                        <span className="table-meta">{campaign.description || 'Тайлбаргүй'}</span>
                      </td>
                      <td>
                        {new Date(campaign.start_date).toLocaleDateString()} - {new Date(campaign.end_date).toLocaleDateString()}
                      </td>
                      <td>{campaign.survey_name || '-'}</td>
                      <td>{campaign.total_tradeshops}</td>
                      <td>{campaign.progress_percent}%</td>
                      <td>
                        <span className={`badge ${status.className}`}>{status.label}</span>
                      </td>
                      <td>
                        <div className="action-buttons">
                          <button
                            className="btn btn-secondary btn-sm"
                            type="button"
                            onClick={() => {
                              setEditingCampaign(campaign);
                              setFormData({
                                name: campaign.name,
                                description: campaign.description || '',
                                start_date: campaign.start_date?.slice(0, 10) || '',
                                end_date: campaign.end_date?.slice(0, 10) || '',
                                survey_id: campaign.survey_id || '',
                                target_tradeshop_ids: campaign.target_tradeshop_ids || [],
                                is_active: campaign.is_active,
                              });
                              setShowModal(true);
                            }}
                          >
                            Засах
                          </button>
                          <button
                            className="btn btn-danger btn-sm"
                            type="button"
                            onClick={async () => {
                              if (!window.confirm(`${campaign.name} кампанит ажлыг устгах уу?`)) {
                                return;
                              }
                              try {
                                await deleteCampaign(campaign.id);
                                await loadData();
                              } catch (err) {
                                setError(err.response?.data?.detail || 'Кампанит ажил устгаж чадсангүй.');
                              }
                            }}
                          >
                            Устгах
                          </button>
                        </div>
                      </td>
                    </tr>
                  );
                })
              )}
            </tbody>
          </table>
        </div>
      </section>

      {showModal && (
        <div className="modal-overlay" onClick={resetModal}>
          <div className="modal" onClick={(event) => event.stopPropagation()}>
            <div className="modal-header">
              <h2>{editingCampaign ? 'Кампанит ажил засах' : 'Кампанит ажил нэмэх'}</h2>
              <button className="modal-close" type="button" onClick={resetModal}>
                &times;
              </button>
            </div>
            <form onSubmit={handleSubmit}>
              <div className="modal-body">
                <div className="form-group">
                  <label htmlFor="campaign-name">Нэр</label>
                  <input
                    id="campaign-name"
                    type="text"
                    value={formData.name}
                    onChange={(event) => setFormData({ ...formData, name: event.target.value })}
                    required
                  />
                </div>

                <div className="form-group">
                  <label htmlFor="campaign-description">Тайлбар</label>
                  <textarea
                    id="campaign-description"
                    value={formData.description}
                    onChange={(event) => setFormData({ ...formData, description: event.target.value })}
                  />
                </div>

                <div className="form-grid">
                  <div className="form-group">
                    <label htmlFor="campaign-start">Эхлэх огноо</label>
                    <input
                      id="campaign-start"
                      type="date"
                      value={formData.start_date}
                      onChange={(event) => setFormData({ ...formData, start_date: event.target.value })}
                      required
                    />
                  </div>
                  <div className="form-group">
                    <label htmlFor="campaign-end">Дуусах огноо</label>
                    <input
                      id="campaign-end"
                      type="date"
                      value={formData.end_date}
                      onChange={(event) => setFormData({ ...formData, end_date: event.target.value })}
                      required
                    />
                  </div>
                </div>

                <div className="form-group">
                  <label htmlFor="campaign-survey">Судалгаа</label>
                  <select
                    id="campaign-survey"
                    value={formData.survey_id}
                    onChange={(event) => setFormData({ ...formData, survey_id: event.target.value })}
                  >
                    <option value="">Сонгоогүй</option>
                    {surveys.map((survey) => (
                      <option key={survey.id} value={survey.id}>
                        {survey.name}
                      </option>
                    ))}
                  </select>
                </div>

                <div className="form-group">
                  <label>Зорилтот дэлгүүрүүд</label>
                  <div className="tags-container">
                    {tradeshops.map((shop) => (
                      <label key={shop.id} className="checkbox-group">
                        <input
                          type="checkbox"
                          checked={formData.target_tradeshop_ids.includes(shop.id)}
                          onChange={() =>
                            setFormData((prev) => ({
                              ...prev,
                              target_tradeshop_ids: prev.target_tradeshop_ids.includes(shop.id)
                                ? prev.target_tradeshop_ids.filter((id) => id !== shop.id)
                                : [...prev.target_tradeshop_ids, shop.id],
                            }))
                          }
                        />
                        {shop.name}
                      </label>
                    ))}
                  </div>
                </div>

                <label className="checkbox-group">
                  <input
                    type="checkbox"
                    checked={formData.is_active}
                    onChange={(event) => setFormData({ ...formData, is_active: event.target.checked })}
                  />
                  Идэвхтэй эсэх
                </label>
              </div>
              <div className="modal-footer">
                <button className="btn btn-secondary" type="button" onClick={resetModal}>
                  Болих
                </button>
                <button className="btn btn-primary" type="submit">
                  {editingCampaign ? 'Хадгалах' : 'Үүсгэх'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};

export default Campaigns;
