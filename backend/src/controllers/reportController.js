const Report = require('../models/Report');

exports.createReport = async (req, res, next) => {
  try {
    const reporterId = req.user._id;
    const { targetType, targetId, reason, description, evidenceImages } = req.body;

    if (!targetType || !targetId || !reason || !description) {
      return res.status(400).json({
        success: false,
        message: 'Target type, target ID, reason, and description are required.'
      });
    }

    const report = await Report.create({
      reporterId,
      targetType,
      targetId,
      reason,
      description: description.trim(),
      evidenceImages: evidenceImages || [],
      status: 'PENDING'
    });

    res.status(201).json({
      success: true,
      message: 'Report submitted. Our moderation team will investigate this report.',
      data: report
    });
  } catch (error) {
    next(error);
  }
};
