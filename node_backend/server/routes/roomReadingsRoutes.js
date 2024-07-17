import express from 'express';
import { createRoomReadingHandler, getRoomReadingsHandler } from '../controllers/roomReadingsController.js';

const router = express.Router();

router.post('/create', createRoomReadingHandler);
router.get('/:surveyID', getRoomReadingsHandler);

export default router;
