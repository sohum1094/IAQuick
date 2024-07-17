import { createSurvey, getSurveyById } from '../models/surveyModel.js';

export const createSurveyService = async (surveyData) => {
    return await createSurvey(surveyData);
};

export const getSurveyService = async (id) => {
    return await getSurveyById(id);
};
