import express from 'express';
const app = express();

import t_router from './todo/t_router.js'

app.use(express.json());

app.use('/todo', t_router);

export default app;