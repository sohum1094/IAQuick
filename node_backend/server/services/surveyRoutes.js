import pool from '../db/index.js';

export const createSurvey = async (surveyData) => {
    const client = await pool.connect();
    try {
        // Insert survey data into survey_info table
        const res = await client.query(
            `INSERT INTO survey_info (siteName, date, address, occupancyType, carbonDioxideReadings, carbonMonoxideReadings, vocs, pm25, pm10) 
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9) RETURNING *`,
            [surveyData.siteName, surveyData.date, surveyData.address, surveyData.occupancyType, surveyData.carbonDioxideReadings, surveyData.carbonMonoxideReadings, surveyData.vocs, surveyData.pm25, surveyData.pm10]
        );
        return res.rows[0];
    } finally {
        client.release();
    }
};

export const exportSurveyData = async (id) => {
    const client = await pool.connect();
    try {
        const survey = await client.query('SELECT * FROM survey_info WHERE ID = $1', [id]);
        const outdoorReadings = await client.query('SELECT * FROM outdoor_readings WHERE surveyID = $1', [id]);
        const roomReadings = await client.query('SELECT * FROM room_readings WHERE surveyID = $1', [id]);

        return {
            survey: survey.rows[0],
            outdoorReadings: outdoorReadings.rows,
            roomReadings: roomReadings.rows,
        };
    } finally {
        client.release();
    }
};
