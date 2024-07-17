import dotenv from 'dotenv';
import path from 'path';

// have to modify dotenv file path becuase the app is run from seeder folder
dotenv.config({ path: path.join(process.cwd(), "..", ".env") })
dotenv.config();

console.log('DB_USERNAME:', process.env.DB_USERNAME); // Verify this outputs the correct value


export default {
  port: process.env.EXPRESS_PORT || 3000,
  db: {
    user: process.env.DB_USERNAME || 'yourUsername',
    host: process.env.DB_HOST || 'localhost',
    database: process.env.DB_NAME || 'postgres',
    password: process.env.DB_PASSWORD || 'yourPassword',
    port: process.env.DB_PORT || 6432,
  }
};
