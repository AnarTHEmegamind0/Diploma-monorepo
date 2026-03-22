import React, { useEffect, useState } from 'react';
import {
  createTradeshop,
  deleteTradeshop,
  getAuditors,
  getCategories,
  getGroups,
  getTradeshops,
  updateTradeshop,
} from '../services/api';
import './shared.css';

const emptyForm = {
  name: '',
  address: '',
  phone: '',
  group_id: '',
  category_id: '',
  assigned_auditor_id: '',
  latitude: '',
  longitude: '',
  is_active: true,
};

const Tradeshops = () => {
  const [tradeshops, setTradeshops] = useState([]);
  const [groups, setGroups] = useState([]);
  const [categories, setCategories] = useState([]);
  const [auditors, setAuditors] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [searchTerm, setSearchTerm] = useState('');
  const [filterGroup, setFilterGroup] = useState('');
  const [showModal, setShowModal] = useState(false);
  const [editingTradeshop, setEditingTradeshop] = useState(null);
  const [formData, setFormData] = useState(emptyForm);

  const loadData = async () => {
    try {
      setLoading(true);
      const [shopData, groupData, categoryData, auditorData] = await Promise.all([
        getTradeshops(),
        getGroups(),
        getCategories({ type: 'product' }),
        getAuditors(),
      ]);
      setTradeshops(shopData);
      setGroups(groupData);
      setCategories(categoryData);
      setAuditors(auditorData);
    } catch (err) {
      setError('Дэлгүүрийн мэдээлэл ачаалж чадсангүй.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadData();
  }, []);

  const resetModal = () => {
    setEditingTradeshop(null);
    setFormData(emptyForm);
    setShowModal(false);
  };

  const handleSubmit = async (event) => {
    event.preventDefault();
    setError('');

    const payload = {
      name: formData.name,
      address: formData.address || null,
      phone: formData.phone || null,
      group_id: formData.group_id || null,
      category_id: formData.category_id || null,
      assigned_auditor_id: formData.assigned_auditor_id || null,
      is_active: formData.is_active,
      location:
        formData.latitude && formData.longitude
          ? {
              lat: parseFloat(formData.latitude),
              lng: parseFloat(formData.longitude),
            }
          : null,
    };

    try {
      if (editingTradeshop) {
        await updateTradeshop(editingTradeshop.id, payload);
      } else {
        await createTradeshop(payload);
      }
      resetModal();
      await loadData();
    } catch (err) {
      setError(err.response?.data?.detail || 'Дэлгүүр хадгалж чадсангүй.');
    }
  };

  const filteredShops = tradeshops.filter((shop) => {
    const matchesSearch =
      shop.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      (shop.address || '').toLowerCase().includes(searchTerm.toLowerCase());
    const matchesGroup = !filterGroup || shop.group_id === filterGroup;
    return matchesSearch && matchesGroup;
  });

  return (
    <div className="page-container">
      <div className="page-header">
        <div>
          <h1>Дэлгүүрүүд</h1>
          <p className="page-subtitle">Аудит хийгдэх дэлгүүрүүдийн байршил, ангилал, хариуцсан аудитор.</p>
        </div>
        <button className="btn btn-primary" type="button" onClick={() => { setEditingTradeshop(null); setFormData(emptyForm); setShowModal(true); }}>
          Дэлгүүр нэмэх
        </button>
      </div>

      {error && <div className="error-message">{error}</div>}

      <section className="filters-panel">
        <div className="filters-bar">
          <input
            className="search-input"
            type="text"
            placeholder="Нэр эсвэл хаягаар хайх..."
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
                <th>Хаяг</th>
                <th>Групп</th>
                <th>Ангилал</th>
                <th>Аудитор</th>
                <th>Төлөв</th>
                <th>Үйлдэл</th>
              </tr>
            </thead>
            <tbody>
              {loading ? (
                <tr>
                  <td colSpan="7" className="table-loading">Ачааллаж байна...</td>
                </tr>
              ) : filteredShops.length === 0 ? (
                <tr>
                  <td colSpan="7">
                    <div className="empty-state compact">
                      <h3>Дэлгүүр олдсонгүй</h3>
                      <p>Шинэ дэлгүүр бүртгэж эхэлнэ үү.</p>
                    </div>
                  </td>
                </tr>
              ) : (
                filteredShops.map((shop) => (
                  <tr key={shop.id}>
                    <td>
                      <span className="table-title">{shop.name}</span>
                      <span className="table-meta">{shop.phone || 'Утасгүй'}</span>
                    </td>
                    <td>{shop.address || '-'}</td>
                    <td>{shop.group_name || '-'}</td>
                    <td>{shop.category_name || '-'}</td>
                    <td>{shop.assigned_auditor_name || '-'}</td>
                    <td>
                      <span className={`badge ${shop.is_active ? 'badge-active' : 'badge-inactive'}`}>
                        {shop.is_active ? 'Идэвхтэй' : 'Идэвхгүй'}
                      </span>
                    </td>
                    <td>
                      <div className="action-buttons">
                        <button
                          className="btn btn-secondary btn-sm"
                          type="button"
                          onClick={() => {
                            setEditingTradeshop(shop);
                            setFormData({
                              name: shop.name,
                              address: shop.address || '',
                              phone: shop.phone || '',
                              group_id: shop.group_id || '',
                              category_id: shop.category_id || '',
                              assigned_auditor_id: shop.assigned_auditor_id || '',
                              latitude: shop.location?.lat || '',
                              longitude: shop.location?.lng || '',
                              is_active: shop.is_active,
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
                            if (!window.confirm(`${shop.name} дэлгүүрийг устгах уу?`)) {
                              return;
                            }
                            try {
                              await deleteTradeshop(shop.id);
                              await loadData();
                            } catch (err) {
                              setError(err.response?.data?.detail || 'Дэлгүүр устгаж чадсангүй.');
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
              <h2>{editingTradeshop ? 'Дэлгүүр засах' : 'Дэлгүүр нэмэх'}</h2>
              <button className="modal-close" type="button" onClick={resetModal}>
                &times;
              </button>
            </div>
            <form onSubmit={handleSubmit}>
              <div className="modal-body">
                <div className="form-grid">
                  <div className="form-group">
                    <label htmlFor="shop-name">Нэр</label>
                    <input
                      id="shop-name"
                      type="text"
                      value={formData.name}
                      onChange={(event) => setFormData({ ...formData, name: event.target.value })}
                      required
                    />
                  </div>
                  <div className="form-group">
                    <label htmlFor="shop-phone">Утас</label>
                    <input
                      id="shop-phone"
                      type="text"
                      value={formData.phone}
                      onChange={(event) => setFormData({ ...formData, phone: event.target.value })}
                    />
                  </div>
                </div>

                <div className="form-group">
                  <label htmlFor="shop-address">Хаяг</label>
                  <input
                    id="shop-address"
                    type="text"
                    value={formData.address}
                    onChange={(event) => setFormData({ ...formData, address: event.target.value })}
                  />
                </div>

                <div className="form-grid">
                  <div className="form-group">
                    <label htmlFor="shop-group">Групп</label>
                    <select
                      id="shop-group"
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
                  <div className="form-group">
                    <label htmlFor="shop-category">Ангилал</label>
                    <select
                      id="shop-category"
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
                </div>

                <div className="form-grid">
                  <div className="form-group">
                    <label htmlFor="shop-auditor">Хариуцсан аудитор</label>
                    <select
                      id="shop-auditor"
                      value={formData.assigned_auditor_id}
                      onChange={(event) => setFormData({ ...formData, assigned_auditor_id: event.target.value })}
                    >
                      <option value="">Сонгоогүй</option>
                      {auditors.map((auditor) => (
                        <option key={auditor.id} value={auditor.id}>
                          {auditor.name}
                        </option>
                      ))}
                    </select>
                  </div>
                  <div className="form-group">
                    <label htmlFor="shop-lat">Координат</label>
                    <div className="form-grid">
                      <input
                        id="shop-lat"
                        type="number"
                        step="any"
                        placeholder="lat"
                        value={formData.latitude}
                        onChange={(event) => setFormData({ ...formData, latitude: event.target.value })}
                      />
                      <input
                        type="number"
                        step="any"
                        placeholder="lng"
                        value={formData.longitude}
                        onChange={(event) => setFormData({ ...formData, longitude: event.target.value })}
                      />
                    </div>
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
                  {editingTradeshop ? 'Хадгалах' : 'Үүсгэх'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};

export default Tradeshops;
