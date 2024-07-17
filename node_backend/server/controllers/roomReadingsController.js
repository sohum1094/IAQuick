import { createRoomReadingService, getRoomReadingsService } from '../services/roomReadingsService.js';

export const createRoomReadingHandler = async (req, res) => {
    const readingData = req.body;
    const newReading = await createRoomReadingService(readingData);
    res.json(newReading);
};

export const getRoomReadingsHandler = async (req, res) => {
    const { surveyID } = req.params;
    const readings = await getRoomReadingsService(surveyID);
    res.json(readings);
};
