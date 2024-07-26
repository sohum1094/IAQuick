import express from 'express';
import {
    createRoomReadingHandler, getRoomReadingByRoomIdHandler, getRoomReadingsLastHandler, getRoomReadingsBySurveyIdHandler,
    updateRoomReadingByRoomIdHandler, deleteRoomReadingsBySurveyIdHandler, deleteRoomReadingsByRoomIdHandler
} from '../controllers/roomReadingsController.js';

const router = express.Router();

router.post('/create', createRoomReadingHandler);
router.get('/room/:roomID', getRoomReadingByRoomIdHandler)
router.get('/survey/:surveyID', getRoomReadingsBySurveyIdHandler);
router.get('/room/last', getRoomReadingsLastHandler);
router.put('/room/:roomID', updateRoomReadingByRoomIdHandler);
router.delete('/survey/:surveyID', deleteRoomReadingsBySurveyIdHandler);
router.delete('/room/:roomID', deleteRoomReadingsByRoomIdHandler)



export default router;
