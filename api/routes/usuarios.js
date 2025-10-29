const express = require('express');
const router = express.Router();
const pool = require('../db');

function devError(res, err, fallbackMsg = 'Error interno') {
  console.error('[USUARIOS] Error >>>', err);
  return res.status(500).json({
    ok: false,
    error: fallbackMsg,
    detail: {
      code: err.code || null,
      errno: err.errno || null,
      sqlMessage: err.sqlMessage || null,
    },
  });
}

// POST /usuarios/register
router.post('/register', async (req, res) => {
  try {
    const { nombre, telefono, password, correo = null } = req.body || {};

    if (!nombre || !telefono || !password) {
      return res.status(400).json({ ok: false, error: 'Faltan campos requeridos' });
    }

    const [existe] = await pool.query(
      'SELECT id FROM usuarios WHERE telefono = ? LIMIT 1',
      [telefono]
    );
    if (existe.length > 0) {
      return res.status(409).json({ ok: false, error: 'El teléfono ya está registrado' });
    }

    const [ins] = await pool.query(
      'INSERT INTO usuarios (nombre, telefono, correo, password_hash) VALUES (?, ?, ?, ?)',
      [nombre, telefono, correo, password]
    );

    return res.json({
      ok: true,
      usuario: { id: ins.insertId, nombre, telefono, correo },
    });
  } catch (err) {
    return devError(res, err, 'No se pudo registrar el usuario');
  }
});

// POST /usuarios/login
router.post('/login', async (req, res) => {
  try {
    const { telefono, password } = req.body || {};
    if (!telefono || !password) {
      return res.status(400).json({ ok: false, error: 'Teléfono y contraseña requeridos' });
    }

    const [rows] = await pool.query(
      'SELECT id, nombre, telefono, correo, password_hash FROM usuarios WHERE telefono = ? LIMIT 1',
      [telefono]
    );
    if (rows.length === 0) {
      return res.status(401).json({ ok: false, error: 'Credenciales inválidas' });
    }

    const u = rows[0];
    if (u.password_hash !== password) {
      return res.status(401).json({ ok: false, error: 'Credenciales inválidas' });
    }

    return res.json({
      ok: true,
      usuario: { id: u.id, nombre: u.nombre, telefono: u.telefono, correo: u.correo },
    });
  } catch (err) {
    return devError(res, err, 'No se pudo iniciar sesión');
  }
});

module.exports = router;
