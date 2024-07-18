import express from 'express';
import { createSurveyHandler, getSurveyHandler, getSurveyLastHandler, updateSurveyHandler, deleteSurveyHandler } from '../controllers/surveyController.js';

const router = express.Router();

router.post('/create', createSurveyHandler);
router.get('/:id', getSurveyHandler);
router.get('/lastSurvey/', getSurveyLastHandler);
router.put('/:id', updateSurveyHandler);
router.delete('/:id', deleteSurveyHandler);

export default router;
