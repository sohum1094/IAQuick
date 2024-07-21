import { createSurvey, getSurveyById, getSurveyLast, updateSurveyById, deleteSurveyById } from '../models/surveyModel.js';

export const createSurveyService = async (surveyData) => {
    return await createSurvey(surveyData);
};

export const getSurveyService = async (id) => {
    return await getSurveyById(id);
};

export const getSurveyLastService = async () => {
    return await getSurveyLast();
};

export const updateSurveyService = async (id, newSurveyData) => {
    return await updateSurveyById(id, newSurveyData);
};

export const deleteSurveyService = async (id) => {
    return await deleteSurveyById(id);
};
