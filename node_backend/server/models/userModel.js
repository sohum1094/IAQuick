import pool from '../db/index.js';

export const createUser = async (userData) => {
    const { email, firstName, lastName } = userData;
    const client = await pool.connect();
    try {
        const res = await client.query(
            `INSERT INTO user_info (email, firstName, lastName) 
            VALUES ($1, $2, $3) 
            RETURNING *`,
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
        if (res.rows.length === 0) {
            const error = new Error('User not found');
            error.status = 404;
            throw error;
        }
        return res.rows[0];
    } finally {
        client.release();
    }
};

export const updateUserById = async (id, newUserData) => {
    const { email, firstName, lastName } = newUserData;
    const client = await pool.connect();
    try {
        const res = await client.query(`UPDATE user_info 
                                        SET email = $1,
                                            firstName = $2,
                                            lastName = $3
                                        WHERE ID = $4
                                        RETURNING *`, [email, firstName, lastName, id]);
        if (res.rows.length === 0) {
            const error = new Error('User not found');
            error.status = 404;
            throw error;
        }
        return res.rows[0];
    } finally {
        client.release();
    }
}

export const deleteUserById = async (id) => {
    const client = await pool.connect();
    try {
        const res = await client.query(`DELETE FROM user_info 
                                        WHERE ID = $1
                                        RETURNING *`, [id]);
        return res.rows[0];
    } finally {
        client.release();
    }
}
