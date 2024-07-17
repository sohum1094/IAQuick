import { createOutdoorReadingService, getOutdoorReadingsService } from '../services/outdoorReadingsService.js';

export const createOutdoorReadingHandler = async (req, res) => {
    const readingData = req.body;
    const newReading = await createOutdoorReadingService(readingData);
    res.json(newReading);
};

export const getOutdoorReadingsHandler = async (req, res) => {
    const { surveyID } = req.params;
    const readings = await getOutdoorReadingsService(surveyID);
    res.json(readings);
};
