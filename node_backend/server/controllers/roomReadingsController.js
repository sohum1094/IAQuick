import {
    createRoomReadingService, getRoomReadingsBySurveyIdService, getRoomReadingByRoomIdService, getRoomReadingsLastService,
    updateRoomReadingByRoomIdService, deleteRoomReadingsBySurveyIdService, deleteRoomReadingByRoomIdService
} from '../services/roomReadingsService.js';

export const createRoomReadingHandler = async (req, res) => {
    const readingData = req.body;
    try {
        const newReading = await createRoomReadingService(readingData);
        res.json(newReading);
    } catch (error) {
        res.status(error.status || 500).json({error: error.message });
    }
    
};

export const getRoomReadingsBySurveyIdHandler = async (req, res) => {
    const { surveyID } = req.params;
    try {
        const readings = await getRoomReadingsBySurveyIdService(surveyID);
        res.json(readings);
    } catch (error) {
        res.status(error.status || 500).json({error: error.message });
    }
    
};

export const getRoomReadingByRoomIdHandler = async (req, res) => {
    const { roomID } = req.params;
    try {
        const readings = await getRoomReadingByRoomIdService(roomID);
        res.json(readings);
    } catch (error) {
        res.status(error.status || 500).json({error: error.message });
    }
    
};

export const getRoomReadingsLastHandler = async (req, res) => {
    try {
        const readings = await getRoomReadingsLastService();
        res.json(readings);
    } catch (error) {
        res.status(error.status || 500).json({error: error.message });
    }
    
};

export const updateRoomReadingByRoomIdHandler = async (req, res) => {
    const { roomID } = req.params;
    try {
        const newReadingData = req.body;
        const updatedReading = await updateRoomReadingByRoomIdService(roomID, newReadingData);
        res.json(updatedReading);
    } catch (error) {
        res.status(error.status || 500).json({error: error.message });
    }
};

export const deleteRoomReadingsBySurveyIdHandler = async (req, res) => {
    const { surveyID } = req.params;
    try {
        const readings = await deleteRoomReadingsBySurveyIdService(surveyID);
        res.json(readings);
    } catch (error) {
        res.status(error.status || 500).json({error: error.message });
    }
    
};

export const deleteRoomReadingsByRoomIdHandler = async (req, res) => {
    const { roomID } = req.params;
    try {
        const readings = await deleteRoomReadingByRoomIdService(roomID);
        res.json(readings);
    } catch (error) {
        res.status(error.status || 500).json({error: error.message });
    }
    
};
