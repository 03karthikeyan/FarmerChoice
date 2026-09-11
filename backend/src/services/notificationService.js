const admin = require('firebase-admin');
const Notification = require('../models/Notification');
const User = require('../models/User');

let ioInstance = null;
let isFirebaseInitialized = false;

// Initialize Firebase Admin SDK
try {
  if (process.env.FIREBASE_SERVICE_ACCOUNT) {
    const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount)
    });
    isFirebaseInitialized = true;
    console.log('✅ Firebase Admin SDK initialized with Service Account.');
  } else if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
    admin.initializeApp({
      credential: admin.credential.applicationDefault()
    });
    isFirebaseInitialized = true;
    console.log('✅ Firebase Admin SDK initialized with Default Credentials.');
  } else {
    // Initialize with project ID if available
    admin.initializeApp({
      projectId: process.env.FIREBASE_PROJECT_ID || 'farmer-choice-60e9d'
    });
    isFirebaseInitialized = true;
    console.log('✅ Firebase Admin SDK initialized for project farmer-choice-60e9d.');
  }
} catch (e) {
  console.warn('⚠️ Firebase Admin initialization notice:', e.message);
}

/**
 * Register the global Socket.IO instance for real-time notifications
 */
exports.setIoInstance = (io) => {
  ioInstance = io;
};

/**
 * Send real-time notification (Database + Socket.IO + Firebase FCM Push)
 */
exports.sendNotification = async ({
  userId,
  title,
  body,
  type = 'SYSTEM_ANNOUNCEMENT',
  referenceId = null,
  referenceType = null,
  data = {}
}) => {
  try {
    if (!userId || !title || !body) return null;

    // 1. Persist notification in MongoDB
    const notification = await Notification.create({
      userId,
      title,
      body,
      type,
      referenceId: referenceId || undefined,
      referenceType: referenceType || undefined
    });

    // 2. Real-time in-app notification via Socket.IO
    if (ioInstance) {
      ioInstance.to(`user:${userId.toString()}`).emit('new_notification', {
        id: notification._id,
        title,
        body,
        type,
        referenceId: referenceId ? referenceId.toString() : null,
        referenceType,
        createdAt: notification.createdAt,
        isRead: false
      });
    }

    // 3. Send Push Notification via Firebase Cloud Messaging (FCM)
    try {
      const user = await User.findById(userId).select('fcmToken name');
      if (user && user.fcmToken && isFirebaseInitialized) {
        const payload = {
          token: user.fcmToken,
          notification: {
            title: title,
            body: body
          },
          data: {
            type: String(type),
            referenceId: referenceId ? String(referenceId) : '',
            referenceType: referenceType ? String(referenceType) : '',
            click_action: 'FLUTTER_NOTIFICATION_CLICK',
            ...Object.keys(data).reduce((acc, key) => {
              acc[key] = String(data[key]);
              return acc;
            }, {})
          },
          android: {
            priority: 'high',
            notification: {
              channelId: 'farmer_choice_notifications',
              sound: 'default',
              priority: 'high',
              clickAction: 'FLUTTER_NOTIFICATION_CLICK'
            }
          }
        };

        const response = await admin.messaging().send(payload);
        console.log(`📲 FCM push sent to user ${userId}:`, response);
      }
    } catch (fcmErr) {
      console.log(`ℹ️ FCM push dispatch: ${fcmErr.message}`);
    }

    return notification;
  } catch (err) {
    console.error('Error in sendNotification service:', err.message);
    return null;
  }
};

/**
 * Send push notification only via FCM
 */
exports.sendPushNotification = async ({ userId, title, body, data = {} }) => {
  try {
    if (!userId || !title || !body || !isFirebaseInitialized) return;
    const user = await User.findById(userId).select('fcmToken');
    if (!user || !user.fcmToken) return;

    const payload = {
      token: user.fcmToken,
      notification: { title, body },
      data: {
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
        ...Object.keys(data).reduce((acc, key) => {
          acc[key] = String(data[key]);
          return acc;
        }, {})
      },
      android: {
        priority: 'high',
        notification: {
          channelId: 'farmer_choice_notifications',
          sound: 'default',
          priority: 'high',
          clickAction: 'FLUTTER_NOTIFICATION_CLICK'
        }
      }
    };

    const response = await admin.messaging().send(payload);
    console.log(`📲 FCM push sent to user ${userId}:`, response);
    return response;
  } catch (err) {
    console.log(`ℹ️ FCM push dispatch: ${err.message}`);
  }
};
