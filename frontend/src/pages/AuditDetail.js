import React, { useEffect, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { getAuditResponse } from '../services/api';
import './shared.css';
import './AuditDetail.css';

const AuditDetail = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const [response, setResponse] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [selectedImage, setSelectedImage] = useState(null);

  useEffect(() => {
    const loadData = async () => {
      try {
        setLoading(true);
        const data = await getAuditResponse(id);
        setResponse(data);
      } catch (err) {
        setError('Аудитын мэдээлэл ачаалж чадсангүй.');
      } finally {
        setLoading(false);
      }
    };
    loadData();
  }, [id]);

  const getResultBadgeClass = (result) => {
    switch (result) {
      case 'pass':
        return 'badge-success';
      case 'warning':
        return 'badge-warning';
      case 'fail':
        return 'badge-danger';
      default:
        return 'badge-neutral';
    }
  };

  const getResultLabel = (result) => {
    switch (result) {
      case 'pass':
        return 'Амжилттай';
      case 'warning':
        return 'Анхааруулга';
      case 'fail':
        return 'Амжилтгүй';
      default:
        return result || '-';
    }
  };

  if (loading) {
    return (
      <div className="page-container">
        <div className="loading-state">
          <div className="loading-spinner"></div>
          <p>Ачааллаж байна...</p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="page-container">
        <div className="error-state">
          <h2>Алдаа гарлаа</h2>
          <p>{error}</p>
          <button className="btn btn-primary" onClick={() => navigate('/audit-results')}>
            Буцах
          </button>
        </div>
      </div>
    );
  }

  if (!response) {
    return (
      <div className="page-container">
        <div className="error-state">
          <h2>Олдсонгүй</h2>
          <p>Аудитын мэдээлэл олдсонгүй.</p>
          <button className="btn btn-primary" onClick={() => navigate('/audit-results')}>
            Буцах
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="page-container">
      <div className="page-header">
        <div className="page-header-back">
          <button className="btn btn-ghost" onClick={() => navigate('/audit-results')}>
            <span className="back-arrow">&larr;</span> Буцах
          </button>
        </div>
        <div className="page-header-content">
          <h1>Аудитын дэлгэрэнгүй</h1>
          <p className="page-subtitle">ID: {response.id}</p>
        </div>
        <div className="page-actions">
          <span className={`badge ${getResultBadgeClass(response.audit_result)}`}>
            {getResultLabel(response.audit_result)}
          </span>
        </div>
      </div>

      {/* Summary Cards */}
      <section className="detail-summary-grid">
        <div className="content-card summary-card">
          <span className="summary-label">Кампанит ажил</span>
          <span className="summary-value">{response.campaign_name || '-'}</span>
        </div>
        <div className="content-card summary-card">
          <span className="summary-label">Дэлгүүр</span>
          <span className="summary-value">{response.tradeshop_name || '-'}</span>
        </div>
        <div className="content-card summary-card">
          <span className="summary-label">Аудитор</span>
          <span className="summary-value">{response.auditor_name || '-'}</span>
        </div>
        <div className="content-card summary-card">
          <span className="summary-label">Илгээсэн огноо</span>
          <span className="summary-value">{new Date(response.submitted_at).toLocaleString()}</span>
        </div>
      </section>

      {/* Photos Section */}
      <section className="detail-section">
        <div className="section-header">
          <h2>Зургууд</h2>
          <span className="badge badge-neutral">{response.photo_urls?.length || 0}</span>
        </div>
        <div className="photos-grid">
          {(response.photo_urls || []).length === 0 ? (
            <div className="empty-photos">
              <p>Зураг байхгүй байна</p>
            </div>
          ) : (
            response.photo_urls.map((url, index) => (
              <div
                key={index}
                className="photo-card"
                onClick={() => setSelectedImage(url)}
              >
                <img src={url} alt={`Audit photo ${index + 1}`} />
                <div className="photo-overlay">
                  <span>Томруулах</span>
                </div>
              </div>
            ))
          )}
        </div>
      </section>

      {/* Detection Results */}
      <section className="detail-section">
        <div className="section-header">
          <h2>AI Илрүүлэлтийн үр дүн</h2>
          <div className="section-badges">
            <span className="badge badge-active">{response.detection_total || 0} бүтээгдэхүүн</span>
            <span className="badge badge-neutral">{Math.round(response.detection_processing_time_ms || 0)}ms</span>
          </div>
        </div>

        {response.detection_summary && Object.keys(response.detection_summary).length > 0 ? (
          <div className="detection-summary">
            {Object.entries(response.detection_summary).map(([className, count]) => (
              <div key={className} className="detection-item">
                <span className="detection-name">{className}</span>
                <span className="detection-count">{count}</span>
              </div>
            ))}
          </div>
        ) : (
          <div className="empty-detection">
            <p>Илрүүлэлтийн үр дүн алга байна</p>
          </div>
        )}

        {response.detection_items && response.detection_items.length > 0 && (
          <div className="detection-details">
            <h3>Дэлгэрэнгүй илрүүлэлт</h3>
            <div className="detection-list">
              {response.detection_items.map((item, index) => (
                <div key={index} className="detection-detail-item">
                  <span className="detection-class">{item.class_name}</span>
                  <span className="detection-confidence">
                    {Math.round((item.confidence || 0) * 100)}%
                  </span>
                </div>
              ))}
            </div>
          </div>
        )}
      </section>

      {/* Answers Section */}
      <section className="detail-section">
        <div className="section-header">
          <h2>Судалгааны хариултууд</h2>
          <span className="badge badge-neutral">{response.answers?.length || 0}</span>
        </div>

        {(response.answers || []).length === 0 ? (
          <div className="empty-answers">
            <p>Хариулт алга байна</p>
          </div>
        ) : (
          <div className="answers-list">
            {response.answers.map((answer, index) => (
              <div key={answer.question_id || index} className="answer-item">
                <div className="answer-header">
                  <span className="answer-number">Q{index + 1}</span>
                  {answer.auto_answered && (
                    <span className="badge badge-ai">AI</span>
                  )}
                </div>
                <div className="answer-content">
                  <p className="answer-question">{answer.question_text}</p>
                  <p className="answer-value">
                    {Array.isArray(answer.answer)
                      ? answer.answer.join(', ')
                      : String(answer.answer)}
                  </p>
                </div>
              </div>
            ))}
          </div>
        )}
      </section>

      {/* Notes Section */}
      {response.notes && (
        <section className="detail-section">
          <div className="section-header">
            <h2>Тэмдэглэл</h2>
          </div>
          <div className="notes-content">
            <p>{response.notes}</p>
          </div>
        </section>
      )}

      {/* Location Section */}
      {response.location && (
        <section className="detail-section">
          <div className="section-header">
            <h2>Байршил</h2>
          </div>
          <div className="location-content">
            <p>
              <strong>Lat:</strong> {response.location.lat?.toFixed(6)},
              <strong> Lng:</strong> {response.location.lng?.toFixed(6)}
            </p>
            {response.location.accuracy && (
              <p><strong>Нарийвчлал:</strong> {response.location.accuracy.toFixed(1)}м</p>
            )}
          </div>
        </section>
      )}

      {/* Image Modal */}
      {selectedImage && (
        <div className="image-modal-overlay" onClick={() => setSelectedImage(null)}>
          <div className="image-modal-content" onClick={(e) => e.stopPropagation()}>
            <button className="image-modal-close" onClick={() => setSelectedImage(null)}>
              &times;
            </button>
            <img src={selectedImage} alt="Full size" />
          </div>
        </div>
      )}
    </div>
  );
};

export default AuditDetail;
