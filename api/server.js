require('dotenv').config();
const express = require('express');
const cors = require('cors');
const pool = require('./db');

// --- IMPORTAR RUTAS ---
const disponibilidadRoutes = require('./routes/disponibilidad');
const citasRoutes = require('./routes/citas');
const barberosRoutes = require('./routes/barberos');
const serviciosRoutes = require('./routes/servicios');
const usuariosRoutes = require('./routes/usuarios');

const app = express();

// --- MIDDLEWARES ---
app.use(cors({
  origin: '*', // Permite peticiones desde Flutter (Android, iOS, Web)
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));
app.use(express.json());

// --- PRUEBAS BÁSICAS ---
app.get('/ping', (req, res) => {
  res.json({ ok: true, message: 'API barberapp viva ✅' });
});

app.get('/test-db', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT 1 + 1 AS resultado');
    res.json({ ok: true, db: rows[0].resultado });
  } catch (err) {
    console.error('❌ ERROR DB >>>', err);
    res.status(500).json({ ok: false, error: 'No se pudo conectar a la base de datos' });
  }
});

// --- USO DE RUTAS PRINCIPALES ---
app.use('/barberos', barberosRoutes);
app.use('/servicios', serviciosRoutes);
app.use('/disponibilidad', disponibilidadRoutes);
app.use('/citas', citasRoutes);
app.use('/usuarios', usuariosRoutes);

// --- MANEJO DE RUTA NO ENCONTRADA ---
app.use((req, res) => {
  res.status(404).json({ ok: false, error: 'Ruta no encontrada' });
});

// --- INICIO DEL SERVIDOR ---
const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`✅ API escuchando en http://localhost:${PORT}`);
});
