import express from 'express';
import { createSurveyHandler, getSurveyHandler } from '../controllers/surveyController.js';

const router = express.Router();

router.post('/create', createSurveyHandler);
router.get('/:id', getSurveyHandler);

export default router;
