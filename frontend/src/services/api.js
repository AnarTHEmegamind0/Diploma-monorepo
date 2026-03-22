import axios from 'axios';

const API_BASE = process.env.REACT_APP_API_URL || 'http://localhost:8000/api';

const api = axios.create({
  baseURL: API_BASE,
  headers: { 'Content-Type': 'application/json' },
});

api.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('token');
      localStorage.removeItem('user');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

// ==================== AUTH ====================
export const login = async (phone, password) => {
  const res = await api.post('/auth/login', { phone, password });
  return res.data;
};

export const getMe = async () => {
  const res = await api.get('/auth/me');
  return res.data;
};

export const initAdmin = async () => {
  const res = await api.post('/auth/init-admin');
  return res.data;
};

// ==================== AUDITORS ====================
export const getAuditors = async (params = {}) => {
  const res = await api.get('/auditors/', { params });
  return res.data;
};

export const createAuditor = async (data) => {
  const res = await api.post('/auditors/', data);
  return res.data;
};

export const updateAuditor = async (id, data) => {
  const res = await api.put(`/auditors/${id}`, data);
  return res.data;
};

export const deleteAuditor = async (id) => {
  const res = await api.delete(`/auditors/${id}`);
  return res.data;
};

// ==================== GROUPS ====================
export const getGroups = async (params = {}) => {
  const res = await api.get('/groups/', { params });
  return res.data;
};

export const createGroup = async (data) => {
  const res = await api.post('/groups/', data);
  return res.data;
};

export const updateGroup = async (id, data) => {
  const res = await api.put(`/groups/${id}`, data);
  return res.data;
};

export const deleteGroup = async (id) => {
  const res = await api.delete(`/groups/${id}`);
  return res.data;
};

// ==================== TRADESHOPS ====================
export const getTradeshops = async (params = {}) => {
  const res = await api.get('/tradeshops/', { params });
  return res.data;
};

export const createTradeshop = async (data) => {
  const res = await api.post('/tradeshops/', data);
  return res.data;
};

export const updateTradeshop = async (id, data) => {
  const res = await api.put(`/tradeshops/${id}`, data);
  return res.data;
};

export const deleteTradeshop = async (id) => {
  const res = await api.delete(`/tradeshops/${id}`);
  return res.data;
};

// ==================== CATEGORIES ====================
export const getCategories = async (params = {}) => {
  const res = await api.get('/categories/', { params });
  return res.data;
};

export const createCategory = async (data) => {
  const res = await api.post('/categories/', data);
  return res.data;
};

export const updateCategory = async (id, data) => {
  const res = await api.put(`/categories/${id}`, data);
  return res.data;
};

export const deleteCategory = async (id) => {
  const res = await api.delete(`/categories/${id}`);
  return res.data;
};

// ==================== CAMPAIGNS ====================
export const getCampaigns = async (params = {}) => {
  const res = await api.get('/campaigns/', { params });
  return res.data;
};

export const getCampaign = async (id) => {
  const res = await api.get(`/campaigns/${id}`);
  return res.data;
};

export const createCampaign = async (data) => {
  const res = await api.post('/campaigns/', data);
  return res.data;
};

export const updateCampaign = async (id, data) => {
  const res = await api.put(`/campaigns/${id}`, data);
  return res.data;
};

export const deleteCampaign = async (id) => {
  const res = await api.delete(`/campaigns/${id}`);
  return res.data;
};

export const getCampaignStats = async (id) => {
  const res = await api.get(`/campaigns/${id}/stats`);
  return res.data;
};

// ==================== SURVEYS ====================
export const getSurveys = async (params = {}) => {
  const res = await api.get('/surveys/', { params });
  return res.data;
};

export const getSurvey = async (id) => {
  const res = await api.get(`/surveys/${id}`);
  return res.data;
};

export const createSurvey = async (data) => {
  const res = await api.post('/surveys/', data);
  return res.data;
};

export const updateSurvey = async (id, data) => {
  const res = await api.put(`/surveys/${id}`, data);
  return res.data;
};

export const deleteSurvey = async (id) => {
  const res = await api.delete(`/surveys/${id}`);
  return res.data;
};

export const getQuestionTypes = async () => {
  const res = await api.get('/surveys/question-types');
  return res.data;
};

export const createQuestionGroup = async (surveyId, data) => {
  const res = await api.post(`/surveys/${surveyId}/groups`, { ...data, survey_id: surveyId });
  return res.data;
};

export const updateQuestionGroup = async (groupId, data) => {
  const res = await api.put(`/surveys/groups/${groupId}`, data);
  return res.data;
};

export const deleteQuestionGroup = async (groupId) => {
  const res = await api.delete(`/surveys/groups/${groupId}`);
  return res.data;
};

export const reorderQuestionGroups = async (surveyId, groupIds) => {
  const res = await api.put(`/surveys/${surveyId}/groups/reorder`, {
    question_ids: groupIds,
  });
  return res.data;
};

export const createQuestion = async (surveyId, data) => {
  const res = await api.post(`/surveys/${surveyId}/questions`, { ...data, survey_id: surveyId });
  return res.data;
};

export const updateQuestion = async (questionId, data) => {
  const res = await api.put(`/surveys/questions/${questionId}`, data);
  return res.data;
};

export const deleteQuestion = async (questionId) => {
  const res = await api.delete(`/surveys/questions/${questionId}`);
  return res.data;
};

export const reorderQuestions = async (surveyId, questionIds) => {
  const res = await api.put(`/surveys/${surveyId}/questions/reorder`, {
    question_ids: questionIds,
  });
  return res.data;
};

// ==================== AUDIT RESPONSES ====================
export const getAuditResponses = async (params = {}) => {
  const res = await api.get('/audit-submit/responses', { params });
  return res.data;
};

export const getAuditResponse = async (id) => {
  const res = await api.get(`/audit-submit/responses/${id}`);
  return res.data;
};

// ==================== DASHBOARD / LEGACY ====================
export const getAuditStats = async () => {
  const res = await api.get('/audit/stats');
  return res.data;
};

export default api;
