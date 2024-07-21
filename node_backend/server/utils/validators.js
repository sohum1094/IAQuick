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

        // Temperature must be a number and within specified range
        if (field === 'temperature') {
            if (!isNumber(value)) {
                isValid = false;
                errors.push(`${field} should be a number`);
            } else if (value < 68 || value > 76) {
                errors.push(`${field} is outside the comfortable range (68-76 F)`);
            }
        }

        // Relative humidity must be a number and within specified range
        if (field === 'relativeHumidity') {
            if (!isNumber(value)) {
                isValid = false;
                errors.push(`${field} should be a number`);
            } else if (value > 65) {
                errors.push(`${field} is above the recommended level (65%)`);
            }
        }

        // CO2 must be a number and greater than 700
        if (field === 'co2' && (!isNumber(value) || value <= 700)) {
            isValid = false;
            errors.push(`${field} should be a number greater than 700 ppm`);
        }

        // CO must be a number and greater than 10
        if (field === 'co' && (!isNumber(value) || value <= 10)) {
            isValid = false;
            errors.push(`${field} should be a number greater than 10 ppm`);
        }

        // VOCs must be a number and greater than 3.0
        if (field === 'vocs' && (!isNumber(value) || value <= 3.0)) {
            isValid = false;
            errors.push(`${field} should be a number greater than 3.0 mg/m^3`);
        }

        // PM2.5 must be a number and greater than 35
        if (field === 'pm25' && (!isNumber(value) || value <= 35)) {
            isValid = false;
            errors.push(`${field} should be a number greater than 35 µg/m^3`);
        }

        // PM10 must be a number and greater than 150
        if (field === 'pm10' && (!isNumber(value) || value <= 150)) {
            isValid = false;
            errors.push(`${field} should be a number greater than 150 µg/m^3`);
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
    const expectedReadings = ['Carbon Dioxide', 'Carbon Monoxide', 'VOCs', 'PM2.5', 'PM10'];
    let isValid = true;

    // Check if all required readings are present and have a boolean value
    expectedReadings.forEach(reading => {
        if (readings[reading] === undefined || typeof readings[reading] !== 'boolean') {
            isValid = false;
        }
    });

    return isValid;
}

export { validateRoomReadings, validateSurveyReadingsCheckbox };
