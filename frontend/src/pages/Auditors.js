import React, { useEffect, useState } from 'react';
import { createAuditor, deleteAuditor, getAuditors, getGroups, updateAuditor } from '../services/api';
import './shared.css';

const emptyForm = {
  name: '',
  phone: '',
  email: '',
  group_id: '',
  password: '',
  is_active: true,
};

const Auditors = () => {
  const [auditors, setAuditors] = useState([]);
  const [groups, setGroups] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [searchTerm, setSearchTerm] = useState('');
  const [filterGroup, setFilterGroup] = useState('');
  const [showModal, setShowModal] = useState(false);
  const [editingAuditor, setEditingAuditor] = useState(null);
  const [formData, setFormData] = useState(emptyForm);

  const loadData = async () => {
    try {
      setLoading(true);
      const [auditorData, groupData] = await Promise.all([getAuditors(), getGroups()]);
      setAuditors(auditorData);
      setGroups(groupData);
    } catch (err) {
      setError('Аудиторын мэдээлэл ачаалж чадсангүй.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadData();
  }, []);

  const resetModal = () => {
    setEditingAuditor(null);
    setFormData(emptyForm);
    setShowModal(false);
  };

  const openCreate = () => {
    setEditingAuditor(null);
    setFormData(emptyForm);
    setShowModal(true);
  };

  const handleEdit = (auditor) => {
    setEditingAuditor(auditor);
    setFormData({
      name: auditor.name,
      phone: auditor.phone,
      email: auditor.email || '',
      group_id: auditor.group_id || '',
      password: '',
      is_active: auditor.is_active,
    });
    setShowModal(true);
  };

  const handleSubmit = async (event) => {
    event.preventDefault();
    setError('');

    try {
      const payload = {
        ...formData,
        group_id: formData.group_id || null,
      };

      if (editingAuditor) {
        if (!payload.password) {
          delete payload.password;
        }
        await updateAuditor(editingAuditor.id, payload);
      } else {
        await createAuditor(payload);
      }

      resetModal();
      await loadData();
    } catch (err) {
      setError(err.response?.data?.detail || 'Үйлдлийг гүйцэтгэж чадсангүй.');
    }
  };

  const handleDelete = async (auditor) => {
    if (!window.confirm(`${auditor.name} аудиторын бүртгэлийг устгах уу?`)) {
      return;
    }

    try {
      await deleteAuditor(auditor.id);
      await loadData();
    } catch (err) {
      setError(err.response?.data?.detail || 'Устгаж чадсангүй.');
    }
  };

  const filteredAuditors = auditors.filter((auditor) => {
    const matchesSearch =
      auditor.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      auditor.phone.includes(searchTerm);
    const matchesGroup = !filterGroup || auditor.group_id === filterGroup;
    return matchesSearch && matchesGroup;
  });

  return (
    <div className="page-container">
      <div className="page-header">
        <div>
          <h1>Аудиторууд</h1>
          <p className="page-subtitle">Хээрийн аудиторын бүртгэл, статус, харьяалсан группыг удирдана.</p>
        </div>
        <button className="btn btn-primary" type="button" onClick={openCreate}>
          Аудитор нэмэх
        </button>
      </div>

      {error && <div className="error-message">{error}</div>}

      <section className="filters-panel">
        <div className="filters-bar">
          <input
            className="search-input"
            type="text"
            placeholder="Нэр эсвэл утсаар хайх..."
            value={searchTerm}
            onChange={(event) => setSearchTerm(event.target.value)}
          />
          <select className="filter-select" value={filterGroup} onChange={(event) => setFilterGroup(event.target.value)}>
            <option value="">Бүх групп</option>
            {groups.map((group) => (
              <option key={group.id} value={group.id}>
                {group.name}
              </option>
            ))}
          </select>
        </div>
      </section>

      <section className="data-table-container">
        <div className="data-table-scroll">
          <table className="data-table">
            <thead>
              <tr>
                <th>Нэр</th>
                <th>Утас</th>
                <th>Групп</th>
                <th>Эрх</th>
                <th>Төлөв</th>
                <th>Үйлдэл</th>
              </tr>
            </thead>
            <tbody>
              {loading ? (
                <tr>
                  <td colSpan="6" className="table-loading">Ачааллаж байна...</td>
                </tr>
              ) : filteredAuditors.length === 0 ? (
                <tr>
                  <td colSpan="6">
                    <div className="empty-state compact">
                      <h3>Аудитор олдсонгүй</h3>
                      <p>Хайлтын нөхцөлөө өөрчлөх эсвэл шинэ аудитор нэмнэ үү.</p>
                    </div>
                  </td>
                </tr>
              ) : (
                filteredAuditors.map((auditor) => (
                  <tr key={auditor.id}>
                    <td>
                      <span className="table-title">{auditor.name}</span>
                      <span className="table-meta">{auditor.email || 'И-мэйлгүй'}</span>
                    </td>
                    <td>{auditor.phone}</td>
                    <td>{auditor.group_name || '-'}</td>
                    <td>
                      <span className={`badge ${auditor.is_admin ? 'badge-admin' : 'badge-neutral'}`}>
                        {auditor.is_admin ? 'Админ' : 'Аудитор'}
                      </span>
                    </td>
                    <td>
                      <span className={`badge ${auditor.is_active ? 'badge-active' : 'badge-inactive'}`}>
                        {auditor.is_active ? 'Идэвхтэй' : 'Идэвхгүй'}
                      </span>
                    </td>
                    <td>
                      <div className="action-buttons">
                        <button className="btn btn-secondary btn-sm" type="button" onClick={() => handleEdit(auditor)}>
                          Засах
                        </button>
                        <button className="btn btn-danger btn-sm" type="button" onClick={() => handleDelete(auditor)}>
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
              <h2>{editingAuditor ? 'Аудитор засах' : 'Аудитор нэмэх'}</h2>
              <button className="modal-close" type="button" onClick={resetModal}>
                &times;
              </button>
            </div>
            <form onSubmit={handleSubmit}>
              <div className="modal-body">
                <div className="form-grid">
                  <div className="form-group">
                    <label htmlFor="auditor-name">Нэр</label>
                    <input
                      id="auditor-name"
                      type="text"
                      value={formData.name}
                      onChange={(event) => setFormData({ ...formData, name: event.target.value })}
                      required
                    />
                  </div>
                  <div className="form-group">
                    <label htmlFor="auditor-phone">Утас</label>
                    <input
                      id="auditor-phone"
                      type="text"
                      value={formData.phone}
                      onChange={(event) => setFormData({ ...formData, phone: event.target.value })}
                      required
                    />
                  </div>
                </div>

                <div className="form-grid">
                  <div className="form-group">
                    <label htmlFor="auditor-email">И-мэйл</label>
                    <input
                      id="auditor-email"
                      type="email"
                      value={formData.email}
                      onChange={(event) => setFormData({ ...formData, email: event.target.value })}
                    />
                  </div>
                  <div className="form-group">
                    <label htmlFor="auditor-group">Групп</label>
                    <select
                      id="auditor-group"
                      value={formData.group_id}
                      onChange={(event) => setFormData({ ...formData, group_id: event.target.value })}
                    >
                      <option value="">Сонгоогүй</option>
                      {groups.map((group) => (
                        <option key={group.id} value={group.id}>
                          {group.name}
                        </option>
                      ))}
                    </select>
                  </div>
                </div>

                <div className="form-group">
                  <label htmlFor="auditor-password">{editingAuditor ? 'Нууц үг (хоосон орхивол хэвээр)' : 'Нууц үг'}</label>
                  <input
                    id="auditor-password"
                    type="password"
                    value={formData.password}
                    onChange={(event) => setFormData({ ...formData, password: event.target.value })}
                    required={!editingAuditor}
                  />
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
                  {editingAuditor ? 'Хадгалах' : 'Үүсгэх'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};

export default Auditors;
