import pool from '../db/index.js';

export const createRoomReading = async (readingData) => {
    const { surveyID, building, floorNumber, roomNumber, primaryUse, temperature, relativeHumidity, co2, co, pm25, pm10, vocs, comments } = readingData;
    const client = await pool.connect();
    try {
        const res = await client.query(
            `INSERT INTO room_readings (surveyID, building, floorNumber, roomNumber, primaryUse, temperature, relativeHumidity, co2, co, pm25, pm10, vocs, comments) 
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13) RETURNING *`,
            [surveyID, building, floorNumber, roomNumber, primaryUse, temperature, relativeHumidity, co2, co, pm25, pm10, vocs, comments]
        );
        return res.rows[0];
    } finally {
        client.release();
    }
};

export const getRoomReadingsBySurveyId = async (surveyID) => {
    const client = await pool.connect();
    try {
        const res = await client.query(`SELECT * FROM room_readings WHERE surveyID = $1`, [surveyID]);
        return res.rows;
    } finally {
        client.release();
    }
};
