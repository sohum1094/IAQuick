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

export const getRoomReadingByRoomId = async (roomID) => {
    const client = await pool.connect();
    try {
        const res = await client.query(`SELECT * FROM room_readings WHERE ID = $1`, [roomID]);
        if (res.rows.length === 0) {
            const error = new Error('Room not found');
            error.status = 404;
            throw error;
        };
        return res.rows[0]
    } finally {
        client.release();
    }
};

export const updateRoomReadingsBySurveyId = async (roomID, newRoomData) => {
    const { surveyID, building, floorNumber, roomNumber, primaryUse, temperature, relativeHumidity, co2, co, pm25, pm10, vocs, comments } = newRoomData;
    const client = await pool.connect();
    try {
        const res = await client.query(
            `UPDATE room_readings 
            SET surveyID = $1,
                building = $2,
                floorNumber = $3,
                roomNumber = $4,
                primaryUse = $5,
                temperature = $6,
                relativeHumidity = $7,
                co2 = $8,
                co = $9,
                pm25 = $10,
                pm10 = $11,
                vocs = $12,
                comments = $13
            WHERE ID = $14
            RETURNING *`,
            [surveyID, building, floorNumber, roomNumber, primaryUse, temperature, relativeHumidity, co2, co, pm25, pm10, vocs, comments, roomID]
        );
        return res.rows[0];
    } finally {
        client.release();
    }
};

export const deleteRoomReadingsBySurveyId = async (surveyID) => {
    const client = await pool.connect();
    try {
        const res = await client.query(
            `DELETE FROM room_readings 
            WHERE surveyID = $1`, [surveyID]);
        if (res.rows.length === 0) {
            const error = new Error('No rooms found for provided surveyID');
            error.status = 404;
            throw error;
        };
        return res.rows[0];

    } finally {
        client.release();
    }
};

export const deleteRoomReadingByRoomId = async (roomID) => {
    const client = await pool.connect();
    try {
        const res = await client.query(
            `DELETE FROM room_readings 
            WHERE ID = $1`, [roomID]);
        if (res.rows.length === 0) {
            const error = new Error('No room found to delete');
            error.status = 404;
            throw error;
        };
        return res.rows[0];

    } finally {
        client.release();
    }
};