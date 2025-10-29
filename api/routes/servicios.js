const express = require('express');
const router = express.Router();
const pool = require('../db');

router.get('/', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT id, nombre, precio FROM servicios ORDER BY nombre');
    res.json(rows);
  } catch (err) {
    console.error('Error al obtener servicios:', err);
    res.status(500).json({ error: 'Error interno al obtener servicios' });
  }
});

module.exports = router;
