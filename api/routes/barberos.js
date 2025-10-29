const express = require('express');
const router = express.Router();
const pool = require('../db');

router.get('/', async (req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT id, nombre, especialidad, foto_url 
      FROM barberos 
      ORDER BY nombre
    `);
    res.json(rows);
  } catch (err) {
    console.error('Error al obtener barberos:', err);
    res.status(500).json({ error: 'Error interno al obtener barberos' });
  }
});

module.exports = router;
