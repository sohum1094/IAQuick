import { getSurvey, createSurvey, exportSurveyData } from '../services/surveyService.js';

export const createSurveyHandler = async (req, res) => {
    const surveyData = req.body;
    const newSurvey = await createSurvey(surveyData);
    res.json(newSurvey);
};

export const exportSurveyHandler = async (req, res) => {
    const { id } = req.params;
    const surveyData = await exportSurveyData(id);
    res.json(surveyData);
};
