import dotenv from 'dotenv';

dotenv.config();

export default {
  port: process.env.EXPRESS_PORT || 3000,
  db: {
    user: process.env.DB_USER || 'yourUsername',
    host: process.env.DB_HOST || 'localhost',
    database: process.env.DB_NAME || 'postgres',
    password: process.env.DB_PASSWORD || 'yourPassword',
    port: process.env.DB_PORT || 6432,
  }
};
