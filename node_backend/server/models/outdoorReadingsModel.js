import pool from '../db/index.js';

export const createOutdoorReading = async (readingData) => {
    const { surveyID, temperature, relativeHumidity, co2, co, pm25, pm10, vocs } = readingData;
    const client = await pool.connect();
    try {
        const res = await client.query(
            `INSERT INTO outdoor_readings (surveyID, temperature, relativeHumidity, co2, co, pm25, pm10, vocs) 
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING *`,
            [surveyID, temperature, relativeHumidity, co2, co, pm25, pm10, vocs]
        );
        return res.rows[0];
    } finally {
        client.release();
    }
};

export const getOutdoorReadingsBySurveyId = async (surveyID) => {
    const client = await pool.connect();
    try {
        const res = await client.query(`SELECT * FROM outdoor_readings WHERE surveyID = $1`, [surveyID]);
        return res.rows;
    } finally {
        client.release();
    }
};
