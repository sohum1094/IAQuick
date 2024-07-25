import {
    createRoomReading, getRoomReadingsBySurveyId, getRoomReadingByRoomId,
    updateRoomReadingsBySurveyId, deleteRoomReadingsBySurveyId, deleteRoomReadingByRoomId
} from '../models/roomReadingsModel.js';

export const createRoomReadingService = async (readingData) => {
    return await createRoomReading(readingData);
};

export const getRoomReadingsBySurveyIdService = async (surveyID) => {
    return await getRoomReadingsBySurveyId(surveyID);
};

export const getRoomReadingByRoomIdService = async (roomID) => {
    return await getRoomReadingByRoomId(roomID);
};

export const updateRoomReadingByRoomIdService = async (roomID, newRoomData) => {
    return await updateRoomReadingsBySurveyId(roomID, newRoomData);
};

export const deleteRoomReadingsBySurveyIdService = async (surveyID) => {
    return await deleteRoomReadingsBySurveyId(surveyID);
};

export const deleteRoomReadingByRoomIdService = async (roomID) => {
    return await deleteRoomReadingByRoomId(roomID);
};

