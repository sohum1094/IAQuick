import 'dotenv/config';
import app from './app.js';
import { runDBMigrations } from './db/migrations/index.js';
import config from './config/config.js';

async function start() {
    try {
        await runDBMigrations();
        
        const port = config.port;

        app.listen(port, () => {
            console.log(`Server running at http://localhost:${port}`);
        });
    } catch (error) {
        console.error('Error starting server:', error);
    }
}

start();
