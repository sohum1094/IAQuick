// User info operations
app.get('/userInfo', (req, res) => {
    // Assuming 'db' is your database connection object
    db.get("SELECT * FROM users WHERE userId = ?", [req.body.userId], (err, row) => {
        if (err) {
            res.status(500).send({ error: 'Failed to retrieve user data' });
        } else if (row) {
            res.send(row);
        } else {
            res.status(404).send({ message: 'User not found' });
        }
    });
});


app.post('/userInfo', (req, res) => {
    const { email, firstName, lastName } = req.body;
    if (!isValidEmail(email) || !isValidName(firstName) || !isValidName(lastName)) {
        res.status(400).send({ message: 'Invalid input' });
    } else {
        // Insert or update database logic here
        db.run("REPLACE INTO users (email, firstName, lastName) VALUES (?, ?, ?)", [email, firstName, lastName], (err) => {
            if (err) {
                res.status(500).send({ error: 'Database error' });
            } else {
                res.send({ message: 'User info saved successfully' });
            }
        });
    }
});



