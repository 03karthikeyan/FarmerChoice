require('dotenv').config();
const http = require('http');
const { Server } = require('socket.io');
const app = require('./app');
const connectDB = require('./config/db');
const setupChatSocket = require('./sockets/chatSocket');
const notificationService = require('./services/notificationService');

const PORT = process.env.PORT || 5000;

const server = http.createServer(app);

// Initialize Socket.IO
const io = new Server(server, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST']
  }
});

// Attach Socket.IO to Express app & notification service
app.set('io', io);
notificationService.setIoInstance(io);

// Setup Chat Socket Handlers
setupChatSocket(io);

// Connect to MongoDB and start server
connectDB().then(() => {
  server.listen(PORT, () => {
    console.log(`=========================================`);
    console.log(`🌱 Farmer Choice Backend Service Started`);
    console.log(`🚀 Port: ${PORT}`);
    console.log(`🌐 Base URL: http://localhost:${PORT}/api/v1`);
    console.log(`⚡ Socket.IO Ready`);
    console.log(`=========================================`);
  });
});

process.on('unhandledRejection', (err) => {
  console.error('Unhandled Promise Rejection:', err.message);
});
