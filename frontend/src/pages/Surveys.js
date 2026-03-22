import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { createSurvey, deleteSurvey, getCategories, getSurveys, updateSurvey } from '../services/api';
import './shared.css';

const emptyForm = {
  name: '',
  description: '',
  category_id: '',
  is_active: true,
};

const Surveys = () => {
  const navigate = useNavigate();
  const [surveys, setSurveys] = useState([]);
  const [categories, setCategories] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [searchTerm, setSearchTerm] = useState('');
  const [showModal, setShowModal] = useState(false);
  const [editingSurvey, setEditingSurvey] = useState(null);
  const [formData, setFormData] = useState(emptyForm);

  const loadData = async () => {
    try {
      setLoading(true);
      const [surveyData, categoryData] = await Promise.all([
        getSurveys(),
        getCategories({ type: 'product' }),
      ]);
      setSurveys(surveyData);
      setCategories(categoryData);
    } catch (err) {
      setError('Судалгааны мэдээлэл ачаалж чадсангүй.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadData();
  }, []);

  const resetModal = () => {
    setEditingSurvey(null);
    setFormData(emptyForm);
    setShowModal(false);
  };

  const handleSubmit = async (event) => {
    event.preventDefault();
    setError('');

    try {
      const payload = {
        ...formData,
        category_id: formData.category_id || null,
      };
      if (editingSurvey) {
        await updateSurvey(editingSurvey.id, payload);
      } else {
        await createSurvey(payload);
      }
      resetModal();
      await loadData();
    } catch (err) {
      setError(err.response?.data?.detail || 'Судалгаа хадгалж чадсангүй.');
    }
  };

  const filteredSurveys = surveys.filter((survey) =>
    survey.name.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const categoryLookup = Object.fromEntries(categories.map((category) => [category.id, category.name]));

  return (
    <div className="page-container">
      <div className="page-header">
        <div>
          <h1>Судалгаа</h1>
          <p className="page-subtitle">Судалгааны загварууд, асуултын бүлэг, асуултын тоог удирдана.</p>
        </div>
        <button className="btn btn-primary" type="button" onClick={() => { setEditingSurvey(null); setFormData(emptyForm); setShowModal(true); }}>
          Судалгаа нэмэх
        </button>
      </div>

      {error && <div className="error-message">{error}</div>}

      <section className="filters-panel">
        <input
          className="search-input"
          type="text"
          placeholder="Судалгаа хайх..."
          value={searchTerm}
          onChange={(event) => setSearchTerm(event.target.value)}
        />
      </section>

      <section className="data-table-container">
        <div className="data-table-scroll">
          <table className="data-table">
            <thead>
              <tr>
                <th>Нэр</th>
                <th>Ангилал</th>
                <th>Бүлэг</th>
                <th>Асуулт</th>
                <th>Төлөв</th>
                <th>Үйлдэл</th>
              </tr>
            </thead>
            <tbody>
              {loading ? (
                <tr>
                  <td colSpan="6" className="table-loading">Ачааллаж байна...</td>
                </tr>
              ) : filteredSurveys.length === 0 ? (
                <tr>
                  <td colSpan="6">
                    <div className="empty-state compact">
                      <h3>Судалгаа олдсонгүй</h3>
                      <p>Шинэ судалгаа үүсгээд builder рүү орно уу.</p>
                    </div>
                  </td>
                </tr>
              ) : (
                filteredSurveys.map((survey) => (
                  <tr key={survey.id}>
                    <td>
                      <span className="table-title">{survey.name}</span>
                      <span className="table-meta">{survey.description || 'Тайлбаргүй'}</span>
                    </td>
                    <td>{categoryLookup[survey.category_id] || '-'}</td>
                    <td>{survey.group_count || 0}</td>
                    <td>{survey.question_count || 0}</td>
                    <td>
                      <span className={`badge ${survey.is_active ? 'badge-active' : 'badge-inactive'}`}>
                        {survey.is_active ? 'Идэвхтэй' : 'Идэвхгүй'}
                      </span>
                    </td>
                    <td>
                      <div className="action-buttons">
                        <button className="btn btn-primary btn-sm" type="button" onClick={() => navigate(`/surveys/${survey.id}/builder`)}>
                          Builder
                        </button>
                        <button
                          className="btn btn-secondary btn-sm"
                          type="button"
                          onClick={() => {
                            setEditingSurvey(survey);
                            setFormData({
                              name: survey.name,
                              description: survey.description || '',
                              category_id: survey.category_id || '',
                              is_active: survey.is_active,
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
                            if (!window.confirm(`${survey.name} судалгааг устгах уу?`)) {
                              return;
                            }
                            try {
                              await deleteSurvey(survey.id);
                              await loadData();
                            } catch (err) {
                              setError(err.response?.data?.detail || 'Судалгаа устгаж чадсангүй.');
                            }
                          }}
                        >
                          Устгах
                        </button>
                      </div>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </section>

      {showModal && (
        <div className="modal-overlay" onClick={resetModal}>
          <div className="modal" onClick={(event) => event.stopPropagation()}>
            <div className="modal-header">
              <h2>{editingSurvey ? 'Судалгаа засах' : 'Судалгаа нэмэх'}</h2>
              <button className="modal-close" type="button" onClick={resetModal}>
                &times;
              </button>
            </div>
            <form onSubmit={handleSubmit}>
              <div className="modal-body">
                <div className="form-group">
                  <label htmlFor="survey-name">Нэр</label>
                  <input
                    id="survey-name"
                    type="text"
                    value={formData.name}
                    onChange={(event) => setFormData({ ...formData, name: event.target.value })}
                    required
                  />
                </div>
                <div className="form-group">
                  <label htmlFor="survey-description">Тайлбар</label>
                  <textarea
                    id="survey-description"
                    value={formData.description}
                    onChange={(event) => setFormData({ ...formData, description: event.target.value })}
                  />
                </div>
                <div className="form-group">
                  <label htmlFor="survey-category">Ангилал</label>
                  <select
                    id="survey-category"
                    value={formData.category_id}
                    onChange={(event) => setFormData({ ...formData, category_id: event.target.value })}
                  >
                    <option value="">Сонгоогүй</option>
                    {categories.map((category) => (
                      <option key={category.id} value={category.id}>
                        {category.name}
                      </option>
                    ))}
                  </select>
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
                  {editingSurvey ? 'Хадгалах' : 'Үүсгэх'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};

export default Surveys;
