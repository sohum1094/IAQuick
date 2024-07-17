import pool from '../db/index.js';

export const createSurvey = async (surveyData) => {
    const { siteName, date, address, occupancyType, carbonDioxideReadings, carbonMonoxideReadings, vocs, pm25, pm10 } = surveyData;
    const client = await pool.connect();
    try {
        const res = await client.query(
            `INSERT INTO survey_info (siteName, date, address, occupancyType, carbonDioxideReadings, carbonMonoxideReadings, vocs, pm25, pm10) 
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9) RETURNING *`,
            [siteName, date, address, occupancyType, carbonDioxideReadings, carbonMonoxideReadings, vocs, pm25, pm10]
        );
        return res.rows[0];
    } finally {
        client.release();
    }
};

export const getSurveyById = async (id) => {
    const client = await pool.connect();
    try {
        const res = await client.query(`SELECT * FROM survey_info WHERE ID = $1`, [id]);
        return res.rows[0];
    } finally {
        client.release();
    }
};
