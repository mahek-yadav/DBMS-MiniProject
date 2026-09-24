const express = require('express');
const cors = require('cors');
const path = require('path');
const { Pool, types } = require('pg');
const queries = require('./queryData');

// Keep DATE columns (OID 1082) as raw 'YYYY-MM-DD' strings to prevent timezone shifts
types.setTypeParser(1082, (val) => val);

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

// PostgreSQL Pool connection
const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    database: process.env.PGDATABASE || 'bloodbanknetwork',
    user: process.env.PGUSER || process.env.USER,
    password: process.env.PGPASSWORD || '',
    host: process.env.PGHOST || 'localhost',
    port: process.env.PGPORT || 5432,
});

// API: Get all pre-defined queries
app.get('/api/queries', (req, res) => {
    res.json(queries);
});

// API: Get quick statistics
app.get('/api/stats', async (req, res) => {
    try {
        const [donors, units, hospitals, requests] = await Promise.all([
            pool.query('SELECT COUNT(*) FROM donor'),
            pool.query('SELECT COUNT(*) FROM blood_unit'),
            pool.query('SELECT COUNT(*) FROM hospital'),
            pool.query('SELECT COUNT(*) FROM hospital_request')
        ]);

        res.json({
            donors: donors.rows[0].count,
            units: units.rows[0].count,
            hospitals: hospitals.rows[0].count,
            requests: requests.rows[0].count
        });
    } catch (err) {
        console.error('Error fetching stats:', err.message);
        res.status(500).json({ error: 'Failed to fetch database statistics' });
    }
});

// API: Execute specific business query by ID
app.get('/api/query/:id', async (req, res) => {
    const id = parseInt(req.params.id, 10);
    const queryObj = queries.find(q => q.id === id);

    if (!queryObj) {
        return res.status(404).json({ error: `Query with ID ${id} not found.` });
    }

    try {
        const result = await pool.query(queryObj.sql);
        res.json({
            id: queryObj.id,
            question: queryObj.question,
            sql: queryObj.sql,
            rowCount: result.rowCount,
            data: result.rows
        });
    } catch (err) {
        console.error(`Error executing Query ${id}:`, err.message);
        res.status(500).json({ error: err.message, sql: queryObj.sql });
    }
});

// API: Fetch raw table data
app.get('/api/table/:tableName', async (req, res) => {
    const allowedTables = ['donor', 'blood_bank', 'donation', 'hospital', 'blood_unit', 'hospital_request'];
    const tableName = req.params.tableName.toLowerCase();

    if (!allowedTables.includes(tableName)) {
        return res.status(400).json({ error: `Invalid table: ${tableName}` });
    }

    const sql = `SELECT * FROM ${tableName} LIMIT 100;`;
    try {
        const result = await pool.query(sql);
        res.json({
            tableName: tableName,
            sql: sql,
            rowCount: result.rowCount,
            data: result.rows
        });
    } catch (err) {
        console.error(`Error fetching table ${tableName}:`, err.message);
        res.status(500).json({ error: err.message, sql: sql });
    }
});

app.listen(PORT, () => {
    console.log(`Server running at http://localhost:${PORT}`);
});
