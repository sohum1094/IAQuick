import express from 'express';
const app = express();
import "body-parser";
import t_router from './todo/t_router.js';
import db from '../db/index.js';

// app.use(express.json());
app.use(bodyParser.json())
app.use(
    bodyParser.urlencoded({
        extended: true,
    })
)
app.use('/todo', t_router);
app.get('/userInfo', db);
app.post('/userInfo', db);
app.delete('/userInfo', db);




export default app;