import { createSurveyService, getSurveyService, getSurveyLastService, updateSurveyService, deleteSurveyService } from '../services/surveyService.js';

export const createSurveyHandler = async (req, res) => {
    try {
        const surveyData = req.body;
        const newSurvey = await createSurveyService(surveyData);
        res.json(newSurvey);
    } catch (error) {
        res.status(error.status || 500).json({ error: error.message });
    }
};

export const getSurveyHandler = async (req, res) => {
    const { id } = req.params;
    try {
        const survey = await getSurveyService(id);
        res.json(survey);
    } catch (error) {
        res.status(error.status || 500).json({error: error.message })
    }
    
};

export const getSurveyLastHandler = async (req, res) => {
    try {
        const survey = await getSurveyLastService();
        res.json(survey);
    } catch (error) {
        res.status(error.status || 500).json({error: error.message })
    }
};


export const updateSurveyHandler = async (req, res) => {
    const { id } = req.params;
    try {
        const surveyData = req.body;
        const updatedSurvey = await updateSurveyService(id, surveyData);
        res.json(updatedSurvey);
    } catch (error) {
        res.status(error.status || 500).json({error: error.message });
    }
};

export const deleteSurveyHandler = async (req, res) => {
    const { id } = req.params;
    try {
        const deletedSurvey = await deleteSurveyService(id);
        res.json(deletedSurvey);
    } catch (error) {
        res.status(error.status || 500).json({error: error.message });
    }
};