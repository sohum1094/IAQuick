import express from 'express';
import { createSurveyHandler, exportSurveyHandler } from '../controllers/surveyController.js';

const router = express.Router();

router.post('/create', createSurveyHandler);
router.get('/export/:id', exportSurveyHandler);

export default router;
