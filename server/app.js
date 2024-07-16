import express from 'express';
const app = express();
import "body-parser";
import t_router from './todo/t_router.js'

// app.use(express.json());
app.use(bodyParser.json())
app.use(
    bodyParser.urlencoded({
        extended: true,
    })
)
app.use('/todo', t_router);

export default app;