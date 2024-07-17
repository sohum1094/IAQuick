import express from 'express';
import { createOutdoorReadingHandler, getOutdoorReadingsHandler } from '../controllers/outdoorReadingsController.js';

const router = express.Router();

router.post('/create', createOutdoorReadingHandler);
router.get('/:surveyID', getOutdoorReadingsHandler);

export default router;
