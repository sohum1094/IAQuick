import { createRoomReading, getRoomReadingsBySurveyId } from '../models/roomReadingsModel.js';

export const createRoomReadingService = async (readingData) => {
    return await createRoomReading(readingData);
};

export const getRoomReadingsService = async (surveyID) => {
    return await getRoomReadingsBySurveyId(surveyID);
};
