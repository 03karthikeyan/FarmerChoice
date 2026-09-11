const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const path = require('path');
const routes = require('./routes');
const errorHandler = require('./middlewares/errorHandler');
const { apiLimiter } = require('./middlewares/rateLimiter');

const app = express();

// Security & Middlewares
app.use(helmet({ crossOriginResourcePolicy: false }));
app.use(cors({ origin: '*', credentials: true }));
app.use(morgan('dev'));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Apply rate limiting to all API requests
app.use('/api', apiLimiter);

// Serve uploads / assets statically
app.use('/uploads', express.static(path.join(__dirname, '../public/uploads')));
app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

// Root & Health Check for Cloud / Render
app.get('/', (req, res) => {
  res.status(200).json({
    success: true,
    message: '🌱 Farmer Choice Direct Marketplace Backend API is live!',
    version: '1.0.0',
    docs: '/api/v1',
    timestamp: new Date().toISOString()
  });
});

app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

// Routes
app.use('/api/v1', routes);

// 404 Handler
app.use((req, res, next) => {
  res.status(404).json({
    success: false,
    message: `API endpoint ${req.originalUrl} not found.`
  });
});

// Centralized error handler
app.use(errorHandler);

module.exports = app;
