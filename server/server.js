// const express = require('express')
// const app = express()
import 'dotenv/config';
import app from './app.js'
import { runDBMigrations} from '../db/migrations/index.js'


async function start() {
    await runDBMigrations();
    
    const port = process.env.EXPRESS_PORT || 3000;

    app.listen(port, () => {
        console.log(`Server running at http://localhost:${port}`)
    });
}

app.get("/", (req,res) => {
    res.json({ message: "Welcome to IAQuick."});
})


start();







  