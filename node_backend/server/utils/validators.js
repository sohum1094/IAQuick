function validateRoomReadings(readings) {
    const expectedReadings = ['surveyID', 'building', 'floorNumber', 'roomNumber', 'primaryUse', 'temperature', 'relativeHumidity', 'co2', 'co', 'pm25', 'pm10', 'vocs', 'comments'];
    let isValid = true;
    let errors = [];

    // Helper function to check if a value is a positive integer
    const isPositiveInt = (value) => Number.isInteger(value) && value > 0;

    // Helper function to check if a value is a number
    const isNumber = (value) => typeof value === 'number' && !isNaN(value);

    // Helper function to check if a value is a string
    const isString = (value) => typeof value === 'string';

    // Iterate through expected readings to validate each field
    for (const field of expectedReadings) {
        const value = readings[field];

        // Survey ID must be a positive integer
        if (field === 'surveyID' && !isPositiveInt(value)) {
            isValid = false;
            errors.push(`${field} should be a positive integer`);
        }

        // Building must be a string
        if (field === 'building' && !isString(value)) {
            isValid = false;
            errors.push(`${field} should be a string`);
        }

        // Floor number can be an integer or a single character (G, B)
        if (field === 'floorNumber' && !(isString(value) && value.length === 1) && !isNumber(value)) {
            isValid = false;
            errors.push(`${field} should be an integer or a single character`);
        }

        // Room number must be a positive integer
        if (field === 'roomNumber' && !isPositiveInt(value)) {
            isValid = false;
            errors.push(`${field} should be a positive integer`);
        }

        // Primary use must be a string
        if (field === 'primaryUse' && !isString(value)) {
            isValid = false;
            errors.push(`${field} should be a string`);
        }

        // Temperature must be a number
        if (field === 'temperature' && !isNumber(value)) {
            isValid = false;
            errors.push(`${field} should be a number`);
        }

        // Relative humidity must be a number
        if (field === 'relativeHumidity' && !isNumber(value)) {
            isValid = false;
            errors.push(`${field} should be a number`);
        }

        // CO2 must be a number
        if (field === 'co2' && !isNumber(value)) {
            isValid = false;
            errors.push(`${field} should be a number`);
        }

        // CO must be a number
        if (field === 'co' && !isNumber(value)) {
            isValid = false;
            errors.push(`${field} should be a number`);
        }

        // VOCs must be a number
        if (field === 'vocs' && !isNumber(value)) {
            isValid = false;
            errors.push(`${field} should be a number`);
        }

        // PM2.5 must be a number
        if (field === 'pm25' && !isNumber(value)) {
            isValid = false;
            errors.push(`${field} should be a number`);
        }

        // PM10 must be a number
        if (field === 'pm10' && !isNumber(value)) {
            isValid = false;
            errors.push(`${field} should be a number`);
        }

        // Comments must be a string if provided
        if (field === 'comments' && value !== undefined && !isString(value)) {
            isValid = false;
            errors.push(`${field} should be a string if provided`);
        }
    }

    return { isValid, errors };
}

function validateSurveyReadingsCheckbox(readings) {
    console.log(readings);
    const expectedReadings = ['carbonDioxideReadings', 'carbonMonoxideReadings', 'vocs', 'pm25', 'pm10'];
    let isValid = true;

    // Check if all required readings are present and have a boolean value
    expectedReadings.forEach(reading => {
        if (readings[reading] === undefined || typeof readings[reading] !== 'boolean') {
            isValid = false;
            console.log(`${reading} is invalid`);
        }
        
    });

    return isValid;
}

export { validateRoomReadings, validateSurveyReadingsCheckbox };
