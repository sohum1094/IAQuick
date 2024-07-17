const express = require('express');
const router = express.Router();

router.post('/submitSurvey', (req, res) => {
    const { siteName, address, date, occupancyType, readings } = req.body;

    if (!siteName || !address || !date || !occupancyType || !validateReadingsCheckbox(readings)) {
        return res.status(400).json({ error: 'All fields are required and must be valid.' });
    }

    // Additional business logic here, such as saving the data to a database

    res.status(200).json({ message: 'Survey data processed successfully', data: req.body });
});

router.post('/outdoorReadings', (req, res) => {
    const readings = req.body.readings;
    const validationErrors = validateReadings(readings);

    if (validationErrors) {
        res.status(400).json({ errors: validationErrors });
    } else {
        // Proceed to store the readings in the database
        storeReadings(readings, (err, result) => {
            if (err) {
                res.status(500).json({ error: 'Failed to store readings' });
            } else {
                res.status(200).json({ message: 'Readings stored successfully', data: result });
            }
        });
    }
});

function validateReadingsCheckbox(readings) {
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

function validateReadings(readings) {
    const readingTypes = ['Temperature', 'Relative Humidity', 'Carbon Dioxide', 'Carbon Monoxide', 'VOCs', 'PM2.5', 'PM10'];
    let errors = {};

    readingTypes.forEach(type => {
        const value = readings[type];
        if (!value) {
            errors[type] = `${type} is required`;
        } else if (!/^\d+(\.\d+)?$/.test(value.toString())) {
            errors[type] = `Enter Correct ${type} Value`;
        }
    });

    return Object.keys(errors).length === 0 ? null : errors;
}


module.exports = router;