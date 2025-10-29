const express = require('express');
const router = express.Router();
const pool = require('../db');

/**
 * GET /citas?usuario_id=1
 * Lista las citas de un usuario.
 */
router.get('/', async (req, res) => {
  const { usuario_id } = req.query;
  if (!usuario_id) {
    return res.status(400).json({ ok: false, error: 'usuario_id requerido' });
  }

  try {
    const [rows] = await pool.query(
      `SELECT c.id, c.fecha, c.hora, c.estado,
              s.nombre  AS servicio,
              b.nombre  AS barbero
       FROM citas c
       JOIN servicios s ON c.servicio_id = s.id
       JOIN barberos  b ON c.barbero_id  = b.id
       WHERE c.usuario_id = ?
       ORDER BY c.fecha DESC, c.hora DESC`,
      [usuario_id]
    );
    return res.json({ ok: true, citas: rows });
  } catch (err) {
    console.error('GET /citas error:', err);
    return res.status(500).json({ ok: false, error: 'Error en el servidor' });
  }
});

/**
 * GET /citas/mias?usuario_id=1
 * Alias de la ruta anterior (por si tu app usa /mias).
 */
router.get('/mias', async (req, res) => {
  const { usuario_id } = req.query;
  if (!usuario_id) {
    return res.status(400).json({ ok: false, error: 'usuario_id requerido' });
  }

  try {
    const [rows] = await pool.query(
      `SELECT c.id, c.fecha, c.hora, c.estado,
              s.nombre  AS servicio,
              b.nombre  AS barbero
       FROM citas c
       JOIN servicios s ON c.servicio_id = s.id
       JOIN barberos  b ON c.barbero_id  = b.id
       WHERE c.usuario_id = ?
       ORDER BY c.fecha DESC, c.hora DESC`,
      [usuario_id]
    );
    return res.json({ ok: true, citas: rows });
  } catch (err) {
    console.error('GET /citas/mias error:', err);
    return res.status(500).json({ ok: false, error: 'Error en el servidor' });
  }
});

/**
 * POST /citas
 * Crea una cita.
 * Body JSON: { usuario_id, barbero_id, servicio_id, fecha:"YYYY-MM-DD", hora:"HH:MM:SS" }
 */
router.post('/', async (req, res) => {
  const { usuario_id, barbero_id, servicio_id, fecha, hora } = req.body;

  if (!usuario_id || !barbero_id || !servicio_id || !fecha || !hora) {
    return res.status(400).json({
      ok: false,
      error: 'Faltan campos: usuario_id, barbero_id, servicio_id, fecha, hora',
    });
  }

  try {
    const [result] = await pool.query(
      `INSERT INTO citas (usuario_id, barbero_id, servicio_id, fecha, hora, estado)
       VALUES (?, ?, ?, ?, ?, 'pendiente')`,
      [usuario_id, barbero_id, servicio_id, fecha, hora]
    );
    return res.json({ ok: true, id: result.insertId });
  } catch (err) {
    console.error('POST /citas error:', err);
    return res.status(500).json({ ok: false, error: 'Error al crear la cita' });
  }
});

/** Fallback del router de /citas (evita 404 confusos) */
router.use((req, res) => {
  return res.status(404).json({ ok: false, error: 'Ruta no encontrada en /citas' });
});

module.exports = router;
