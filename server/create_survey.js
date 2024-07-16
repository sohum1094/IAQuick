const express = require('express');
const { Pool } = require('pg');  // Use pg (PostgreSQL) for database operations
const app = express();
app.use(express.json());

const pool = new Pool({
    user: 'yourUsername',
    host: 'localhost',
    database: 'postgres',
    password: 'yourPassword',
    port: 5432,
});

const createTables = async () => {
    const client = await pool.connect();
    try {
        // Create survey_info table
        await client.query(`
      CREATE TABLE IF NOT EXISTS survey_info (
        ID SERIAL PRIMARY KEY,
        siteName TEXT,
        date TEXT,
        address TEXT,
        occupancyType TEXT,
        carbonDioxideReadings BOOLEAN,
        carbonMonoxideReadings BOOLEAN,
        vocs BOOLEAN,
        pm25 BOOLEAN,
        pm10 BOOLEAN
      );
    `);

        // Create outdoor_readings table
        await client.query(`
      CREATE TABLE IF NOT EXISTS outdoor_readings (
        ID SERIAL PRIMARY KEY,
        surveyID INTEGER REFERENCES survey_info(ID),
        temperature REAL,
        relativeHumidity REAL,
        co2 REAL,
        co REAL,
        pm25 REAL,
        pm10 REAL,
        vocs REAL
      );
    `);

        // Create room_readings table
        await client.query(`
      CREATE TABLE IF NOT EXISTS room_readings (
        ID SERIAL PRIMARY KEY,
        surveyID INTEGER REFERENCES survey_info(ID),
        building TEXT,
        floorNumber TEXT,
        roomNumber TEXT,
        primaryUse TEXT,
        temperature REAL,
        relativeHumidity REAL,
        co2 REAL,
        co REAL,
        pm25 REAL,
        pm10 REAL,
        vocs REAL,
        comments TEXT
      );
    `);
        console.log('Tables created successfully');
    } catch (err) {
        console.error(err);
    } finally {
        client.release();
    }
};





// More endpoints for reading, updating, and deleting surveys and readings
app.get('/exportSurvey/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const survey = await pool.query('SELECT * FROM survey_info WHERE ID = $1', [id]);
        const outdoorReadings = await pool.query('SELECT * FROM outdoor_readings WHERE surveyID = $1', [id]);
        const roomReadings = await pool.query('SELECT * FROM room_readings WHERE surveyID = $1', [id]);

        const result = {
            survey: survey.rows[0],
            outdoorReadings: outdoorReadings.rows,
            roomReadings: roomReadings.rows
        };

        res.json(result);
    } catch (err) {
        console.error(err.message);
    }
});


createTables();
