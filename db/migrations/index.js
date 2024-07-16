import db from "../index.js"
import createTables from "./create_tables.js";

const runDBMigrations = async () => {
    console.log('BEGIN DB MIGRATIONS');
    console.log(process.env.DB_USERNAME);
    const client = await db.connect()

    try {
        await client.query('BEGIN');

        await client.query(createTables);

        await client.query('COMMIT');

        console.log('END DB MIGRATION');
    } catch (e) {
        await client.query('ROLLBACK')

        console.log('DB migration failed');

        throw e
    } finally {
        client.release()
    }
}


export {runDBMigrations} ;

