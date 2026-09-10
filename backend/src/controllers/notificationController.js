const Notification = require('../models/Notification');

exports.getNotifications = async (req, res, next) => {
  try {
    const userId = req.user._id;
    const notifications = await Notification.find({ userId })
      .sort({ createdAt: -1 })
      .limit(50);

    const unreadCount = await Notification.countDocuments({ userId, isRead: false });

    res.status(200).json({
      success: true,
      unreadCount,
      data: notifications
    });
  } catch (error) {
    next(error);
  }
};

exports.markAsRead = async (req, res, next) => {
  try {
    const { id } = req.params;
    const userId = req.user._id;

    if (id === 'all') {
      await Notification.updateMany({ userId, isRead: false }, { isRead: true });
      return res.status(200).json({ success: true, message: 'All notifications marked as read.' });
    }

    await Notification.findOneAndUpdate({ _id: id, userId }, { isRead: true });
    res.status(200).json({ success: true, message: 'Notification marked as read.' });
  } catch (error) {
    next(error);
  }
};
