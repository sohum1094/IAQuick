import express from 'express';
import bodyParser from 'body-parser';
import surveyRoutes from './routes/surveyRoutes.js';

const app = express();

app.use(bodyParser.json());
app.use('/surveys', surveyRoutes);

app.get("/", (req, res) => {
    res.json({ message: "Welcome to IAQuick." });
});

export default app;
