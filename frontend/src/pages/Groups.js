import React, { useEffect, useState } from 'react';
import { createGroup, deleteGroup, getGroups, updateGroup } from '../services/api';
import './shared.css';

const emptyForm = {
  name: '',
  description: '',
};

const Groups = () => {
  const [groups, setGroups] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [searchTerm, setSearchTerm] = useState('');
  const [showModal, setShowModal] = useState(false);
  const [editingGroup, setEditingGroup] = useState(null);
  const [formData, setFormData] = useState(emptyForm);

  const loadGroups = async () => {
    try {
      setLoading(true);
      setGroups(await getGroups());
    } catch (err) {
      setError('Группийн мэдээлэл ачаалж чадсангүй.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadGroups();
  }, []);

  const resetModal = () => {
    setEditingGroup(null);
    setFormData(emptyForm);
    setShowModal(false);
  };

  const handleSubmit = async (event) => {
    event.preventDefault();
    setError('');

    try {
      if (editingGroup) {
        await updateGroup(editingGroup.id, formData);
      } else {
        await createGroup(formData);
      }
      resetModal();
      await loadGroups();
    } catch (err) {
      setError(err.response?.data?.detail || 'Групп хадгалж чадсангүй.');
    }
  };

  const handleDelete = async (group) => {
    if (!window.confirm(`${group.name} группийг устгах уу?`)) {
      return;
    }

    try {
      await deleteGroup(group.id);
      await loadGroups();
    } catch (err) {
      setError(err.response?.data?.detail || 'Групп устгаж чадсангүй.');
    }
  };

  const filteredGroups = groups.filter((group) =>
    group.name.toLowerCase().includes(searchTerm.toLowerCase())
  );

  return (
    <div className="page-container">
      <div className="page-header">
        <div>
          <h1>Группүүд</h1>
          <p className="page-subtitle">Аудитор болон дэлгүүрүүдийг газарзүйн бүсээр бүлэглэнэ.</p>
        </div>
        <button className="btn btn-primary" type="button" onClick={() => { setEditingGroup(null); setFormData(emptyForm); setShowModal(true); }}>
          Групп нэмэх
        </button>
      </div>

      {error && <div className="error-message">{error}</div>}

      <section className="filters-panel">
        <input
          className="search-input"
          type="text"
          placeholder="Групп хайх..."
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
                <th>Тайлбар</th>
                <th>Аудитор</th>
                <th>Дэлгүүр</th>
                <th>Үйлдэл</th>
              </tr>
            </thead>
            <tbody>
              {loading ? (
                <tr>
                  <td colSpan="5" className="table-loading">Ачааллаж байна...</td>
                </tr>
              ) : filteredGroups.length === 0 ? (
                <tr>
                  <td colSpan="5">
                    <div className="empty-state compact">
                      <h3>Групп олдсонгүй</h3>
                      <p>Шинэ групп үүсгэж эхэлнэ үү.</p>
                    </div>
                  </td>
                </tr>
              ) : (
                filteredGroups.map((group) => (
                  <tr key={group.id}>
                    <td>
                      <span className="table-title">{group.name}</span>
                      <span className="table-meta">Үүссэн: {new Date(group.created_at).toLocaleDateString()}</span>
                    </td>
                    <td>{group.description || '-'}</td>
                    <td>
                      <span className="badge badge-neutral">{group.auditor_count}</span>
                    </td>
                    <td>
                      <span className="badge badge-neutral">{group.tradeshop_count || 0}</span>
                    </td>
                    <td>
                      <div className="action-buttons">
                        <button
                          className="btn btn-secondary btn-sm"
                          type="button"
                          onClick={() => {
                            setEditingGroup(group);
                            setFormData({
                              name: group.name,
                              description: group.description || '',
                            });
                            setShowModal(true);
                          }}
                        >
                          Засах
                        </button>
                        <button className="btn btn-danger btn-sm" type="button" onClick={() => handleDelete(group)}>
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
              <h2>{editingGroup ? 'Групп засах' : 'Групп нэмэх'}</h2>
              <button className="modal-close" type="button" onClick={resetModal}>
                &times;
              </button>
            </div>
            <form onSubmit={handleSubmit}>
              <div className="modal-body">
                <div className="form-group">
                  <label htmlFor="group-name">Нэр</label>
                  <input
                    id="group-name"
                    type="text"
                    value={formData.name}
                    onChange={(event) => setFormData({ ...formData, name: event.target.value })}
                    required
                  />
                </div>
                <div className="form-group">
                  <label htmlFor="group-description">Тайлбар</label>
                  <textarea
                    id="group-description"
                    value={formData.description}
                    onChange={(event) => setFormData({ ...formData, description: event.target.value })}
                  />
                </div>
              </div>
              <div className="modal-footer">
                <button className="btn btn-secondary" type="button" onClick={resetModal}>
                  Болих
                </button>
                <button className="btn btn-primary" type="submit">
                  {editingGroup ? 'Хадгалах' : 'Үүсгэх'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};

export default Groups;
