const express = require('express');
const router = express.Router();
const pool = require('../db');

router.get('/', async (req, res) => {
  const { barbero_id, fecha } = req.query;
  try {
    const [rows] = await pool.query(
      'SELECT hora FROM disponibilidad WHERE barbero_id = ? AND fecha = ?',
      [barbero_id, fecha]
    );
    res.json(rows);
  } catch (err) {
    console.error('Error al obtener disponibilidad:', err);
    res.status(500).json({ error: 'Error interno al obtener disponibilidad' });
  }
});

module.exports = router;
