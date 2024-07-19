import {
    createRoomReadingService, getRoomReadingsBySurveyIdService, getRoomReadingHandlerByRoomIdService,
    updateRoomReadingByRoomIdService, deleteRoomReadingsBySurveyIdService, deleteRoomReadingByRoomIdService
} from '../services/roomReadingsService.js';

export const createRoomReadingHandler = async (req, res) => {
    const readingData = req.body;
    const newReading = await createRoomReadingService(readingData);
    res.json(newReading);
};

export const getRoomReadingsBySurveyIdHandler = async (req, res) => {
    const { surveyID } = req.params;
    const readings = await getRoomReadingsBySurveyIdService(surveyID);
    res.json(readings);
};

export const getRoomReadingHandlerByRoomIdHandler = async (req, res) => {
    const { roomID } = req.params;
    const readings = await getRoomReadingHandlerByRoomIdService(roomID);
    res.json(readings);
};

export const updateRoomReadingByRoomIdHandler = async (req, res) => {
    const { roomID } = req.params;
    const newReadingData = req.body;
    const updatedReading = await updateRoomReadingByRoomIdService(roomID, newReadingData);
    res.json(updatedReading);
};

export const deleteRoomReadingsBySurveyIdHandler = async (req, res) => {
    const { surveyID } = req.params;
    const readings = await deleteRoomReadingsBySurveyIdService(surveyID);
    res.json(readings);
};

export const deleteRoomReadingsByRoomIdHandler = async (req, res) => {
    const { roomID } = req.params;
    const readings = await deleteRoomReadingByRoomIdService(roomID);
    res.json(readings);
};
