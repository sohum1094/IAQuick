import pg from 'pg';

const db = new pg.Pool({
    user: process.env.DB_USERNAME,
    host: process.env.DB_HOST,
    database: process.env.DB_NAME,
    password: process.env.DB_PASSWORD,
    port: process.env.DB_PORT,
});


// // User info operations
db.get('/userInfo', (req, res) => {
    // Assuming 'db' is your database connection object
    db.get("SELECT * FROM user_info WHERE userId = ?", [req.body.userId], (err, row) => {
        if (err) {
            res.status(500).send({ error: 'Failed to retrieve user data' });
        } else if (row) {
            res.send(row);
        } else {
            res.status(404).send({ message: 'User not found' });
        }
    });
});


db.post('/userInfo', (req, res) => {
    const { email, firstName, lastName } = req.body;
    if (!isValidEmail(email) || !isValidName(firstName) || !isValidName(lastName)) {
        res.status(400).send({ message: 'Invalid input' });
    } else {
        // Insert or update database logic here
        db.run("REPLACE INTO users_info (email, firstName, lastName) VALUES (?, ?, ?)", [email, firstName, lastName], (err) => {
            if (err) {
                res.status(500).send({ error: 'Database error' });
            } else {
                res.send({ message: 'User info saved successfully' });
            }
        });
    }
});

db.delete('/userInfo', (req, res) => {
    db.run("DELETE FROM users WHERE id = ?", [req.body.userId], (err) => {
        if (err) {
            res.status(500).send({ error: 'Database error' });
        } else {
            res.send({ message: 'User deleted with ID: ${id}' });
        }
    })
});

// // Email Validation
function isValidEmail(email) {
    const pattern = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    return pattern.test(email);
}

// // Name Validation
function isValidName(name) {
    return /^[a-zA-Z ]+$/.test(name);
}

export default db;