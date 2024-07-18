import pool from '../db/index.js';

export const createSurvey = async (surveyData) => {
    const { siteName, date, address, occupancyType, carbonDioxideReadings, carbonMonoxideReadings, vocs, pm25, pm10 } = surveyData;
    const client = await pool.connect();
    try {
        const res = await client.query(
            `INSERT INTO survey_info (siteName, date, address, occupancyType, carbonDioxideReadings, carbonMonoxideReadings, vocs, pm25, pm10) 
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9) 
            RETURNING *`,
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

export const getSurveyLast = async () => {
    const client = await pool.connect();
    try {
        const res = await client.query(`SELECT * FROM survey_info WHERE ID =( SELECT MAX(ID) FROM survey_info)`);
        return res.rows[0];
    } finally {
        client.release();
    }
};

export const updateSurveyById = async (id, newSurveyData) => {
    const { siteName, date, address, occupancyType, carbonDioxideReadings, carbonMonoxideReadings, vocs, pm25, pm10 } = newSurveyData;
    const client = await pool.connect();
    try {
        const res = await client.query(
            `UPDATE survey_info
            SET siteName = $1,
                date = $2,
                address = $3,
                occupancyType = $4,
                carbonDioxideReadings = $5,
                carbonMonoxideReadings = $6,
                vocs = $7,
                pm25 = $8,
                pm10 = $9, 
            WHERE ID = $11 
            RETURNING *`,
            [siteName, date, address, occupancyType, carbonDioxideReadings, carbonMonoxideReadings, vocs, pm25, pm10, id]
        );
        if (res.rows.length === 0) {
            const error = new Error('Survey not found');
            error.status = 404;
            throw error;
        }
        return res.rows[0];
    } finally {
        client.release();
    }
};


export const deleteSurveyById = async (id) => {
    const client = await pool.connect();
    try {
        const res = await client.query(
            `DELETE FROM survey_info 
            WHERE ID = $1
            RETURNING *`,
            [id]);
        return res.rows[0];
    } finally {
        client.release();
    }
};