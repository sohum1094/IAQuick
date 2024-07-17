import { createOutdoorReading, getOutdoorReadingsBySurveyId } from '../models/outdoorReadingsModel.js';

export const createOutdoorReadingService = async (readingData) => {
    return await createOutdoorReading(readingData);
};

export const getOutdoorReadingsService = async (surveyID) => {
    return await getOutdoorReadingsBySurveyId(surveyID);
};
