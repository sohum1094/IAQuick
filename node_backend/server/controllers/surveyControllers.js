import { createSurveyService, getSurveyService } from '../services/surveyService.js';

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
