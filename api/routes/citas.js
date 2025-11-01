const express = require('express');
const router = express.Router();
const pool = require('../db');

/**
 * GET /citas/mis-citas/:usuarioId
 * Devuelve todas las citas de un usuario específico.
 */
router.get('/mis-citas/:usuarioId', async (req, res) => {
  const usuarioId = req.params.usuarioId;

  try {
    const [rows] = await pool.query(
      `
      SELECT 
        c.id,
        c.fecha,
        c.hora,
        c.estado,
        b.nombre AS barbero_nombre,
        s.nombre AS servicio_nombre
      FROM citas c
      JOIN barberos b ON c.barbero_id = b.id
      JOIN servicios s ON c.servicio_id = s.id
      WHERE c.usuario_id = ?
      ORDER BY c.fecha DESC, c.hora DESC
      `,
      [usuarioId]
    );

    return res.json({
      ok: true,
      citas: rows,
    });
  } catch (err) {
    console.error('Error al obtener citas:', err);
    return res.status(500).json({
      ok: false,
      error: 'Error interno al obtener citas',
    });
  }
});

/**
 * (Opcional) Crear cita nueva
 * POST /citas
 * body: { usuario_id, barbero_id, servicio_id, fecha, hora }
 */
router.post('/', async (req, res) => {
  try {
    const {
      usuario_id,
      barbero_id,
      servicio_id,
      fecha,
      hora
    } = req.body;

    if (
      !usuario_id ||
      !barbero_id ||
      !servicio_id ||
      !fecha ||
      !hora
    ) {
      return res.status(400).json({
        ok: false,
        error: 'Faltan datos para crear cita',
      });
    }

    const [result] = await pool.query(
      `
      INSERT INTO citas
        (usuario_id, barbero_id, servicio_id, fecha, hora, estado)
      VALUES (?, ?, ?, ?, ?, 'pendiente')
      `,
      [usuario_id, barbero_id, servicio_id, fecha, hora]
    );

    return res.json({
      ok: true,
      cita_id: result.insertId,
    });
  } catch (err) {
    console.error('Error al crear cita:', err);
    return res.status(500).json({
      ok: false,
      error: 'No se pudo crear la cita',
    });
  }
});

module.exports = router;
