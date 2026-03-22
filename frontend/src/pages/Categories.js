import React, { useEffect, useState } from 'react';
import { createCategory, deleteCategory, getCategories, updateCategory } from '../services/api';
import './shared.css';

const emptyForm = {
  name: '',
  description: '',
  type: 'product',
};

const Categories = () => {
  const [categories, setCategories] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [searchTerm, setSearchTerm] = useState('');
  const [showModal, setShowModal] = useState(false);
  const [editingCategory, setEditingCategory] = useState(null);
  const [formData, setFormData] = useState(emptyForm);

  const loadCategories = async () => {
    try {
      setLoading(true);
      setCategories(await getCategories({ type: 'product' }));
    } catch (err) {
      setError('Ангиллын мэдээлэл ачаалж чадсангүй.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadCategories();
  }, []);

  const resetModal = () => {
    setEditingCategory(null);
    setFormData(emptyForm);
    setShowModal(false);
  };

  const handleSubmit = async (event) => {
    event.preventDefault();
    setError('');

    try {
      if (editingCategory) {
        await updateCategory(editingCategory.id, formData);
      } else {
        await createCategory(formData);
      }
      resetModal();
      await loadCategories();
    } catch (err) {
      setError(err.response?.data?.detail || 'Ангилал хадгалж чадсангүй.');
    }
  };

  const filteredCategories = categories.filter((category) =>
    category.name.toLowerCase().includes(searchTerm.toLowerCase())
  );

  return (
    <div className="page-container">
      <div className="page-header">
        <div>
          <h1>Ангилал</h1>
          <p className="page-subtitle">Бүтээгдэхүүний ангиллын сан. Жишээ нь Ус, Сүү, Ундаа, Гурилан бүтээгдэхүүн.</p>
        </div>
        <button className="btn btn-primary" type="button" onClick={() => { setEditingCategory(null); setFormData(emptyForm); setShowModal(true); }}>
          Ангилал нэмэх
        </button>
      </div>

      {error && <div className="error-message">{error}</div>}

      <section className="filters-panel">
        <input
          className="search-input"
          type="text"
          placeholder="Ангилал хайх..."
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
                <th>Төрөл</th>
                <th>Тайлбар</th>
                <th>Хэрэглээ</th>
                <th>Үйлдэл</th>
              </tr>
            </thead>
            <tbody>
              {loading ? (
                <tr>
                  <td colSpan="5" className="table-loading">Ачааллаж байна...</td>
                </tr>
              ) : filteredCategories.length === 0 ? (
                <tr>
                  <td colSpan="5">
                    <div className="empty-state compact">
                      <h3>Ангилал олдсонгүй</h3>
                      <p>Шинэ ангилал үүсгэж эхэлнэ үү.</p>
                    </div>
                  </td>
                </tr>
              ) : (
                filteredCategories.map((category) => (
                  <tr key={category.id}>
                    <td>
                      <span className="table-title">{category.name}</span>
                      <span className="table-meta">Үүссэн: {new Date(category.created_at).toLocaleDateString()}</span>
                    </td>
                    <td>
                      <span className="badge badge-neutral">{category.type === 'product' ? 'Бүтээгдэхүүн' : 'Дэлгүүр'}</span>
                    </td>
                    <td>{category.description || '-'}</td>
                    <td>{category.item_count || 0}</td>
                    <td>
                      <div className="action-buttons">
                        <button
                          className="btn btn-secondary btn-sm"
                          type="button"
                          onClick={() => {
                            setEditingCategory(category);
                            setFormData({
                              name: category.name,
                              description: category.description || '',
                              type: category.type,
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
                            if (!window.confirm(`${category.name} ангиллыг устгах уу?`)) {
                              return;
                            }
                            try {
                              await deleteCategory(category.id);
                              await loadCategories();
                            } catch (err) {
                              setError(err.response?.data?.detail || 'Ангилал устгаж чадсангүй.');
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
              <h2>{editingCategory ? 'Ангилал засах' : 'Ангилал нэмэх'}</h2>
              <button className="modal-close" type="button" onClick={resetModal}>
                &times;
              </button>
            </div>
            <form onSubmit={handleSubmit}>
              <div className="modal-body">
                <div className="form-group">
                  <label htmlFor="category-name">Нэр</label>
                  <input
                    id="category-name"
                    type="text"
                    value={formData.name}
                    onChange={(event) => setFormData({ ...formData, name: event.target.value })}
                    required
                  />
                </div>
                <div className="form-group">
                  <label htmlFor="category-description">Тайлбар</label>
                  <textarea
                    id="category-description"
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
                  {editingCategory ? 'Хадгалах' : 'Үүсгэх'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};

export default Categories;
