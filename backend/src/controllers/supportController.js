const SupportTicket = require('../models/SupportTicket');

const generateTicketNumber = async () => {
  const count = await SupportTicket.countDocuments();
  return `TKT-${1000 + count + 1}`;
};

exports.createTicket = async (req, res, next) => {
  try {
    const userId = req.user._id;
    const { category, subject, description, attachments } = req.body;

    if (!category || !subject || !description) {
      return res.status(400).json({
        success: false,
        message: 'Category, subject, and description are required.'
      });
    }

    const ticketNumber = await generateTicketNumber();

    const ticket = await SupportTicket.create({
      ticketNumber,
      userId,
      category,
      subject: subject.trim(),
      description: description.trim(),
      attachments: attachments || [],
      status: 'OPEN'
    });

    res.status(201).json({
      success: true,
      message: 'Support ticket submitted. Our support team will assist you shortly.',
      data: ticket
    });
  } catch (error) {
    next(error);
  }
};

exports.getMyTickets = async (req, res, next) => {
  try {
    const userId = req.user._id;
    const tickets = await SupportTicket.find({ userId }).sort({ createdAt: -1 });

    res.status(200).json({
      success: true,
      count: tickets.length,
      data: tickets
    });
  } catch (error) {
    next(error);
  }
};
