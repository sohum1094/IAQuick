import { createSurveyService, getSurveyService, getSurveyLastService, updateSurveyService, deleteSurveyService } from '../services/surveyService.js';

export const createSurveyHandler = async (req, res) => {
    const surveyData = req.body;
    const newSurvey = await createSurveyService(surveyData);
    res.json(newSurvey);
};

export const getSurveyHandler = async (req, res) => {
    const { id } = req.params;
    const survey = await getSurveyService(id);
    res.json(survey);
};

export const getSurveyLastHandler = async (req, res) => {
    const { id } = req.params;
    const survey = await getSurveyLastService();
    res.json(survey);
};


export const updateSurveyHandler = async (req, res) => {
    const { id } = req.params;
    const surveyData = req.body;
    const survey = await updateSurveyService(id, surveyData);
    res.json(survey);
};

export const deleteSurveyHandler = async (req, res) => {
    const { id } = req.params;
    const survey = await deleteSurveyService(id);
    res.json(survey);
};