import React, { useEffect, useMemo, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import {
  createQuestion,
  createQuestionGroup,
  deleteQuestion,
  deleteQuestionGroup,
  getQuestionTypes,
  getSurvey,
  reorderQuestionGroups,
  updateQuestion,
  updateQuestionGroup,
} from '../services/api';
import './shared.css';
import './Surveys.css';

const emptyGroupForm = {
  name: '',
  description: '',
};

const emptyQuestionForm = {
  text: '',
  type: 'yes_no',
  group_id: '',
  optionsText: '',
  required: true,
  detection_based: false,
  product_class: '',
};

const parseOptions = (value) =>
  value
    .split('\n')
    .map((item) => item.trim())
    .filter(Boolean);

const SurveyBuilder = () => {
  const { surveyId } = useParams();
  const navigate = useNavigate();
  const [survey, setSurvey] = useState(null);
  const [questionTypes, setQuestionTypes] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [selectedGroupId, setSelectedGroupId] = useState('');
  const [selectedQuestionId, setSelectedQuestionId] = useState('');
  const [groupModalOpen, setGroupModalOpen] = useState(false);
  const [questionModalOpen, setQuestionModalOpen] = useState(false);
  const [editingGroup, setEditingGroup] = useState(null);
  const [editingQuestion, setEditingQuestion] = useState(null);
  const [groupForm, setGroupForm] = useState(emptyGroupForm);
  const [questionForm, setQuestionForm] = useState(emptyQuestionForm);
  const [questionDraft, setQuestionDraft] = useState(null);

  const loadData = async () => {
    try {
      setLoading(true);
      const [surveyData, typeData] = await Promise.all([getSurvey(surveyId), getQuestionTypes()]);
      setSurvey(surveyData);
      setQuestionTypes(typeData);
      const defaultGroupId = surveyData.groups?.[0]?.id || '';
      setSelectedGroupId((prev) => prev || defaultGroupId);
      const defaultQuestionId = surveyData.groups?.[0]?.questions?.[0]?.id || '';
      setSelectedQuestionId((prev) => prev || defaultQuestionId);
    } catch (err) {
      setError('Survey builder мэдээлэл ачаалж чадсангүй.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadData();
  }, [surveyId]);

  const selectedGroup = useMemo(
    () => survey?.groups?.find((group) => group.id === selectedGroupId) || survey?.groups?.[0] || null,
    [survey, selectedGroupId]
  );
  const selectedQuestion = useMemo(
    () => selectedGroup?.questions?.find((question) => question.id === selectedQuestionId) || selectedGroup?.questions?.[0] || null,
    [selectedGroup, selectedQuestionId]
  );

  useEffect(() => {
    if (!survey?.groups?.length) {
      setSelectedGroupId('');
      setSelectedQuestionId('');
      return;
    }

    if (!selectedGroup) {
      setSelectedGroupId(survey.groups[0].id);
      return;
    }

    if (selectedGroup.questions?.length && !selectedQuestion) {
      setSelectedQuestionId(selectedGroup.questions[0].id);
    }
  }, [survey, selectedGroup, selectedQuestion]);

  useEffect(() => {
    if (!selectedQuestion) {
      setQuestionDraft(null);
      return;
    }

    setQuestionDraft({
      text: selectedQuestion.text,
      type: selectedQuestion.type,
      required: selectedQuestion.required,
      optionsText: (selectedQuestion.options || []).join('\n'),
      detection_based: selectedQuestion.detection_based || false,
      product_class: selectedQuestion.product_class || '',
      group_id: selectedQuestion.group_id,
    });
  }, [selectedQuestion]);

  const selectedType = questionTypes.find((type) => type.code === questionDraft?.type);

  const openGroupModal = (group = null) => {
    setEditingGroup(group);
    setGroupForm(
      group
        ? {
            name: group.name,
            description: group.description || '',
          }
        : emptyGroupForm
    );
    setGroupModalOpen(true);
  };

  const openQuestionModal = (question = null) => {
    const baseGroupId = question?.group_id || selectedGroup?.id || '';
    setEditingQuestion(question);
    setQuestionForm(
      question
        ? {
            text: question.text,
            type: question.type,
            group_id: baseGroupId,
            optionsText: (question.options || []).join('\n'),
            required: question.required,
            detection_based: question.detection_based || false,
            product_class: question.product_class || '',
          }
        : {
            ...emptyQuestionForm,
            group_id: baseGroupId,
          }
    );
    setQuestionModalOpen(true);
  };

  const handleGroupSubmit = async (event) => {
    event.preventDefault();
    try {
      if (editingGroup) {
        await updateQuestionGroup(editingGroup.id, groupForm);
      } else {
        await createQuestionGroup(surveyId, groupForm);
      }
      setGroupModalOpen(false);
      await loadData();
    } catch (err) {
      setError(err.response?.data?.detail || 'Асуултын бүлэг хадгалж чадсангүй.');
    }
  };

  const handleQuestionSubmit = async (event) => {
    event.preventDefault();
    const payload = {
      group_id: questionForm.group_id,
      text: questionForm.text,
      type: questionForm.type,
      options: parseOptions(questionForm.optionsText),
      required: questionForm.required,
      detection_based: questionForm.detection_based,
      product_class: questionForm.detection_based ? questionForm.product_class : null,
    };

    try {
      if (editingQuestion) {
        await updateQuestion(editingQuestion.id, payload);
      } else {
        await createQuestion(surveyId, payload);
      }
      setQuestionModalOpen(false);
      await loadData();
    } catch (err) {
      setError(err.response?.data?.detail || 'Асуулт хадгалж чадсангүй.');
    }
  };

  const moveGroup = async (groupId, direction) => {
    const index = survey.groups.findIndex((group) => group.id === groupId);
    const targetIndex = index + direction;
    if (targetIndex < 0 || targetIndex >= survey.groups.length) {
      return;
    }

    const nextOrder = [...survey.groups];
    [nextOrder[index], nextOrder[targetIndex]] = [nextOrder[targetIndex], nextOrder[index]];

    try {
      await reorderQuestionGroups(
        surveyId,
        nextOrder.map((group) => group.id)
      );
      await loadData();
    } catch (err) {
      setError(err.response?.data?.detail || 'Бүлгийн дараалал шинэчилж чадсангүй.');
    }
  };

  const moveQuestion = async (question, direction) => {
    const list = selectedGroup?.questions || [];
    const index = list.findIndex((item) => item.id === question.id);
    const targetIndex = index + direction;
    if (targetIndex < 0 || targetIndex >= list.length) {
      return;
    }

    const neighbor = list[targetIndex];

    try {
      await updateQuestion(question.id, { order: neighbor.order });
      await updateQuestion(neighbor.id, { order: question.order });
      await loadData();
    } catch (err) {
      setError(err.response?.data?.detail || 'Асуултын дараалал шинэчилж чадсангүй.');
    }
  };

  const handleInspectorSave = async () => {
    if (!selectedQuestion || !questionDraft) {
      return;
    }

    try {
      await updateQuestion(selectedQuestion.id, {
        group_id: questionDraft.group_id,
        text: questionDraft.text,
        type: questionDraft.type,
        required: questionDraft.required,
        detection_based: questionDraft.detection_based,
        product_class: questionDraft.detection_based ? questionDraft.product_class : null,
        options: parseOptions(questionDraft.optionsText),
      });
      await loadData();
    } catch (err) {
      setError(err.response?.data?.detail || 'Асуултын тохиргоо хадгалж чадсангүй.');
    }
  };

  if (loading) {
    return (
      <div className="loading-container">
        <div className="loading-spinner" />
        <p>Survey builder ачааллаж байна...</p>
      </div>
    );
  }

  if (!survey) {
    return <div className="error-message">Survey олдсонгүй.</div>;
  }

  return (
    <div className="page-container">
      <div className="page-header">
        <div>
          <h1>Survey Builder</h1>
          <p className="page-subtitle">{survey.name}</p>
        </div>
        <div className="page-actions">
          <button className="btn btn-secondary" type="button" onClick={() => navigate('/surveys')}>
            Буцах
          </button>
          <button className="btn btn-primary" type="button" onClick={loadData}>
            Шинэчлэх
          </button>
        </div>
      </div>

      {error && <div className="error-message">{error}</div>}

      <div className="builder-grid">
        <section className="content-card builder-sidebar">
          <div className="builder-sidebar-top">
            <div>
              <h3>Survey мэдээлэл</h3>
              <p className="page-subtitle">{survey.description || 'Тайлбаргүй судалгаа'}</p>
            </div>
            <div className="builder-badges">
              <span className="badge badge-neutral">{survey.group_count} бүлэг</span>
              <span className="badge badge-neutral">{survey.question_count} асуулт</span>
            </div>
          </div>

          <div className="builder-section-header">
            <h4>Асуултын бүлгүүд</h4>
            <button className="btn btn-primary btn-sm" type="button" onClick={() => openGroupModal()}>
              Бүлэг нэмэх
            </button>
          </div>

          <div className="builder-group-list">
            {survey.groups.length === 0 ? (
              <div className="empty-state compact">
                <p>Бүлэг үүсгээгүй байна.</p>
              </div>
            ) : (
              survey.groups.map((group) => (
                <div
                  key={group.id}
                  className={`builder-group-card ${selectedGroup?.id === group.id ? 'active' : ''}`}
                  role="button"
                  tabIndex={0}
                  onClick={() => {
                    setSelectedGroupId(group.id);
                    setSelectedQuestionId(group.questions?.[0]?.id || '');
                  }}
                  onKeyDown={(event) => {
                    if (event.key === 'Enter' || event.key === ' ') {
                      event.preventDefault();
                      setSelectedGroupId(group.id);
                      setSelectedQuestionId(group.questions?.[0]?.id || '');
                    }
                  }}
                >
                  <span className="table-title">{group.name}</span>
                  <span className="table-meta">{group.question_count} асуулт</span>
                  <div className="builder-inline-actions">
                    <button type="button" className="btn btn-secondary btn-sm" onClick={(event) => { event.stopPropagation(); moveGroup(group.id, -1); }}>
                      Дээш
                    </button>
                    <button type="button" className="btn btn-secondary btn-sm" onClick={(event) => { event.stopPropagation(); moveGroup(group.id, 1); }}>
                      Доош
                    </button>
                    <button type="button" className="btn btn-secondary btn-sm" onClick={(event) => { event.stopPropagation(); openGroupModal(group); }}>
                      Засах
                    </button>
                    <button
                      type="button"
                      className="btn btn-danger btn-sm"
                      onClick={async (event) => {
                        event.stopPropagation();
                        if (!window.confirm(`${group.name} бүлгийг устгах уу?`)) {
                          return;
                        }
                        try {
                          await deleteQuestionGroup(group.id);
                          await loadData();
                        } catch (err) {
                          setError(err.response?.data?.detail || 'Бүлэг устгаж чадсангүй.');
                        }
                      }}
                    >
                      Устгах
                    </button>
                  </div>
                </div>
              ))
            )}
          </div>
        </section>

        <section className="content-card builder-canvas">
          <div className="builder-section-header">
            <div>
              <h3>{selectedGroup?.name || 'Бүлэг сонгоно уу'}</h3>
              <p className="page-subtitle">{selectedGroup?.description || 'Энэ бүлэгт хамаарах асуултууд.'}</p>
            </div>
            {selectedGroup && (
              <button className="btn btn-primary btn-sm" type="button" onClick={() => openQuestionModal()}>
                Асуулт нэмэх
              </button>
            )}
          </div>

          {!selectedGroup ? (
            <div className="empty-state">
              <h3>Бүлэг сонгоогүй байна</h3>
              <p>Зүүн талаас асуултын бүлэг сонгоно уу.</p>
            </div>
          ) : selectedGroup.questions.length === 0 ? (
            <div className="empty-state">
              <h3>Асуулт алга байна</h3>
              <p>Энэ бүлэгт эхний асуултаа нэмнэ үү.</p>
            </div>
          ) : (
            <div className="question-list">
              {selectedGroup.questions
                .slice()
                .sort((a, b) => a.order - b.order)
                .map((question, index) => (
                  <div
                    key={question.id}
                    className={`question-card ${selectedQuestion?.id === question.id ? 'selected' : ''}`}
                    onClick={() => setSelectedQuestionId(question.id)}
                  >
                    <div className="question-card-top">
                      <span className="badge badge-neutral">Q{index + 1}</span>
                      <div className="builder-inline-actions">
                        <button className="btn btn-secondary btn-sm" type="button" onClick={(event) => { event.stopPropagation(); moveQuestion(question, -1); }}>
                          Дээш
                        </button>
                        <button className="btn btn-secondary btn-sm" type="button" onClick={(event) => { event.stopPropagation(); moveQuestion(question, 1); }}>
                          Доош
                        </button>
                        <button className="btn btn-secondary btn-sm" type="button" onClick={(event) => { event.stopPropagation(); openQuestionModal(question); }}>
                          Засах
                        </button>
                        <button
                          className="btn btn-danger btn-sm"
                          type="button"
                          onClick={async (event) => {
                            event.stopPropagation();
                            if (!window.confirm('Энэ асуултыг устгах уу?')) {
                              return;
                            }
                            try {
                              await deleteQuestion(question.id);
                              await loadData();
                            } catch (err) {
                              setError(err.response?.data?.detail || 'Асуулт устгаж чадсангүй.');
                            }
                          }}
                        >
                          Устгах
                        </button>
                      </div>
                    </div>
                    <div className="question-card-body">
                      <span className="table-title">{question.text}</span>
                      <div className="tags-container">
                        <span className="tag">
                          {questionTypes.find((type) => type.code === question.type)?.name || question.type}
                        </span>
                        {question.required && <span className="tag">Заавал</span>}
                        {question.detection_based && <span className="tag">AI detection</span>}
                      </div>
                    </div>
                  </div>
                ))}
            </div>
          )}
        </section>

        <section className="content-card builder-inspector">
          <div className="builder-section-header">
            <h3>Inspector</h3>
          </div>
          {!selectedQuestion || !questionDraft ? (
            <div className="empty-state compact">
              <p>Асуулт сонгож дэлгэрэнгүй тохиргоо харах боломжтой.</p>
            </div>
          ) : (
            <div className="filters-stack">
              <div className="form-group">
                <label>Асуултын текст</label>
                <textarea
                  value={questionDraft.text}
                  onChange={(event) => setQuestionDraft({ ...questionDraft, text: event.target.value })}
                />
              </div>

              <div className="form-group">
                <label>Асуултын төрөл</label>
                <select
                  value={questionDraft.type}
                  onChange={(event) => setQuestionDraft({ ...questionDraft, type: event.target.value })}
                >
                  {questionTypes.map((type) => (
                    <option key={type.code} value={type.code}>
                      {type.name}
                    </option>
                  ))}
                </select>
                <span className="form-help">{selectedType?.description}</span>
              </div>

              <div className="form-group">
                <label>Харьяалах бүлэг</label>
                <select
                  value={questionDraft.group_id}
                  onChange={(event) => setQuestionDraft({ ...questionDraft, group_id: event.target.value })}
                >
                  {survey.groups.map((group) => (
                    <option key={group.id} value={group.id}>
                      {group.name}
                    </option>
                  ))}
                </select>
              </div>

              {selectedType?.has_options && (
                <div className="form-group">
                  <label>Сонголтууд</label>
                  <textarea
                    value={questionDraft.optionsText}
                    onChange={(event) => setQuestionDraft({ ...questionDraft, optionsText: event.target.value })}
                    placeholder="Мөр тус бүрд нэг сонголт"
                  />
                </div>
              )}

              <label className="checkbox-group">
                <input
                  type="checkbox"
                  checked={questionDraft.required}
                  onChange={(event) => setQuestionDraft({ ...questionDraft, required: event.target.checked })}
                />
                Заавал хариулах
              </label>

              <label className="checkbox-group">
                <input
                  type="checkbox"
                  checked={questionDraft.detection_based}
                  onChange={(event) => setQuestionDraft({ ...questionDraft, detection_based: event.target.checked })}
                />
                YOLO detection-оор auto-answer хийх
              </label>

              {questionDraft.detection_based && (
                <div className="form-group">
                  <label>Product class</label>
                  <input
                    type="text"
                    value={questionDraft.product_class}
                    onChange={(event) => setQuestionDraft({ ...questionDraft, product_class: event.target.value })}
                    placeholder="Жишээ: coca_cola"
                  />
                </div>
              )}

              <button className="btn btn-primary" type="button" onClick={handleInspectorSave}>
                Тохиргоо хадгалах
              </button>
            </div>
          )}
        </section>
      </div>

      {groupModalOpen && (
        <div className="modal-overlay" onClick={() => setGroupModalOpen(false)}>
          <div className="modal" onClick={(event) => event.stopPropagation()}>
            <div className="modal-header">
              <h2>{editingGroup ? 'Бүлэг засах' : 'Бүлэг нэмэх'}</h2>
              <button className="modal-close" type="button" onClick={() => setGroupModalOpen(false)}>
                &times;
              </button>
            </div>
            <form onSubmit={handleGroupSubmit}>
              <div className="modal-body">
                <div className="form-group">
                  <label>Нэр</label>
                  <input
                    type="text"
                    value={groupForm.name}
                    onChange={(event) => setGroupForm({ ...groupForm, name: event.target.value })}
                    required
                  />
                </div>
                <div className="form-group">
                  <label>Тайлбар</label>
                  <textarea
                    value={groupForm.description}
                    onChange={(event) => setGroupForm({ ...groupForm, description: event.target.value })}
                  />
                </div>
              </div>
              <div className="modal-footer">
                <button className="btn btn-secondary" type="button" onClick={() => setGroupModalOpen(false)}>
                  Болих
                </button>
                <button className="btn btn-primary" type="submit">
                  Хадгалах
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {questionModalOpen && (
        <div className="modal-overlay" onClick={() => setQuestionModalOpen(false)}>
          <div className="modal" onClick={(event) => event.stopPropagation()}>
            <div className="modal-header">
              <h2>{editingQuestion ? 'Асуулт засах' : 'Асуулт нэмэх'}</h2>
              <button className="modal-close" type="button" onClick={() => setQuestionModalOpen(false)}>
                &times;
              </button>
            </div>
            <form onSubmit={handleQuestionSubmit}>
              <div className="modal-body">
                <div className="form-group">
                  <label>Текст</label>
                  <textarea
                    value={questionForm.text}
                    onChange={(event) => setQuestionForm({ ...questionForm, text: event.target.value })}
                    required
                  />
                </div>
                <div className="form-grid">
                  <div className="form-group">
                    <label>Төрөл</label>
                    <select
                      value={questionForm.type}
                      onChange={(event) => setQuestionForm({ ...questionForm, type: event.target.value })}
                    >
                      {questionTypes.map((type) => (
                        <option key={type.code} value={type.code}>
                          {type.name}
                        </option>
                      ))}
                    </select>
                  </div>
                  <div className="form-group">
                    <label>Бүлэг</label>
                    <select
                      value={questionForm.group_id}
                      onChange={(event) => setQuestionForm({ ...questionForm, group_id: event.target.value })}
                      required
                    >
                      {survey.groups.map((group) => (
                        <option key={group.id} value={group.id}>
                          {group.name}
                        </option>
                      ))}
                    </select>
                  </div>
                </div>
                {questionTypes.find((type) => type.code === questionForm.type)?.has_options && (
                  <div className="form-group">
                    <label>Сонголтууд</label>
                    <textarea
                      value={questionForm.optionsText}
                      onChange={(event) => setQuestionForm({ ...questionForm, optionsText: event.target.value })}
                      placeholder="Мөр тус бүрд нэг сонголт"
                    />
                  </div>
                )}
                <label className="checkbox-group">
                  <input
                    type="checkbox"
                    checked={questionForm.required}
                    onChange={(event) => setQuestionForm({ ...questionForm, required: event.target.checked })}
                  />
                  Заавал хариулах
                </label>
                <label className="checkbox-group">
                  <input
                    type="checkbox"
                    checked={questionForm.detection_based}
                    onChange={(event) => setQuestionForm({ ...questionForm, detection_based: event.target.checked })}
                  />
                  AI detection
                </label>
                {questionForm.detection_based && (
                  <div className="form-group">
                    <label>Product class</label>
                    <input
                      type="text"
                      value={questionForm.product_class}
                      onChange={(event) => setQuestionForm({ ...questionForm, product_class: event.target.value })}
                    />
                  </div>
                )}
              </div>
              <div className="modal-footer">
                <button className="btn btn-secondary" type="button" onClick={() => setQuestionModalOpen(false)}>
                  Болих
                </button>
                <button className="btn btn-primary" type="submit">
                  Хадгалах
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};

export default SurveyBuilder;
