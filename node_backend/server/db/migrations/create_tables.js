const createTables = `
    
    CREATE TABLE IF NOT EXISTS user_info (
        ID SERIAL PRIMARY KEY,
        email TEXT,
        firstName TEXT,
        lastName TEXT
    );


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
`;

export default createTables;