import pool from '../db/index.js';

export const createUser = async (userData) => {
    const { email, firstName, lastName } = userData;
    const client = await pool.connect();
    try {
        const res = await client.query(
            `INSERT INTO user_info (email, firstName, lastName) VALUES ($1, $2, $3) RETURNING *`,
            [email, firstName, lastName]
        );
        return res.rows[0];
    } finally {
        client.release();
    }
};

export const getUserById = async (id) => {
    const client = await pool.connect();
    try {
        const res = await client.query(`SELECT * FROM user_info WHERE ID = $1`, [id]);
        return res.rows[0];
    } finally {
        client.release();
    }
};
