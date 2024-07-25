import express from 'express';
import bodyParser from 'body-parser';
import surveyRoutes from './routes/surveyRoutes.js';
import userRoutes from './routes/userRoutes.js';
import roomReadingsRoutes from './routes/roomReadingsRoutes.js';

const app = express();

app.use(bodyParser.json());
app.use('/users', userRoutes);
app.use('/surveys', surveyRoutes);
app.use('/room-readings', roomReadingsRoutes);

app.get("/", (req, res) => {
    res.json({ message: "Welcome to IAQuick." });
});

export default app;
