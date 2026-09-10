const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Ensure upload directory exists
const uploadDir = path.join(__dirname, '../../public/uploads');
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

// Storage configuration
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
    const ext = path.extname(file.originalname) || '.jpg';
    cb(null, `${file.fieldname}-${uniqueSuffix}${ext}`);
  }
});

// File filter for images
const fileFilter = (req, file, cb) => {
  if (file.mimetype.startsWith('image/')) {
    cb(null, true);
  } else {
    cb(new Error('Only image files are allowed!'), false);
  }
};

const upload = multer({
  storage,
  limits: { fileSize: 10 * 1024 * 1024 }, // 10MB limit
  fileFilter
});

// Upload single image
router.post('/', upload.single('image'), (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'Please upload an image file.'
      });
    }

    const fileUrl = `/uploads/${req.file.filename}`;

    res.status(200).json({
      success: true,
      message: 'Image uploaded successfully.',
      data: {
        url: fileUrl,
        filename: req.file.filename,
        size: req.file.size
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Image upload failed: ' + error.message
    });
  }
});

// Upload base64 image (useful for mobile camera / web canvas)
router.post('/base64', (req, res) => {
  try {
    const { base64Data, filename = 'image.jpg' } = req.body;
    if (!base64Data) {
      return res.status(400).json({
        success: false,
        message: 'No base64 data provided.'
      });
    }

    const matches = base64Data.match(/^data:([A-Za-z-+\/]+);base64,(.+)$/);
    let buffer;
    let ext = '.jpg';

    if (matches && matches.length === 3) {
      const mime = matches[1];
      ext = mime.includes('png') ? '.png' : mime.includes('webp') ? '.webp' : '.jpg';
      buffer = Buffer.from(matches[2], 'base64');
    } else {
      buffer = Buffer.from(base64Data, 'base64');
    }

    const uniqueName = `upload-${Date.now()}-${Math.round(Math.random() * 1e9)}${ext}`;
    const filePath = path.join(uploadDir, uniqueName);
    fs.writeFileSync(filePath, buffer);

    res.status(200).json({
      success: true,
      message: 'Base64 image saved successfully.',
      data: {
        url: `/uploads/${uniqueName}`,
        filename: uniqueName
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Base64 upload failed: ' + error.message
    });
  }
});

module.exports = router;
