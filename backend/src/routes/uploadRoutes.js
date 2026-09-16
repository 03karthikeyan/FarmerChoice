const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const cloudinary = require('cloudinary').v2;

// Cloudinary Configuration
const CLOUD_NAME = process.env.CLOUDINARY_CLOUD_NAME || 'siqyjesm';
const API_KEY = process.env.CLOUDINARY_API_KEY || '314699939554315';
const API_SECRET = process.env.CLOUDINARY_API_SECRET;

cloudinary.config({
  cloud_name: CLOUD_NAME,
  api_key: API_KEY,
  api_secret: API_SECRET
});

const isCloudinaryActive = () => {
  return Boolean(CLOUD_NAME && API_KEY && API_SECRET);
};

// Ensure local upload directory exists as fallback
const uploadDir = path.join(__dirname, '../../public/uploads');
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

// Memory storage for fast streaming to Cloudinary or disk fallback
const storage = multer.memoryStorage();

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

// Upload stream helper for Cloudinary
const uploadStreamToCloudinary = (fileBuffer, originalname) => {
  return new Promise((resolve, reject) => {
    const stream = cloudinary.uploader.upload_stream(
      {
        folder: 'farmer_choice',
        resource_type: 'image'
      },
      (error, result) => {
        if (error) return reject(error);
        resolve(result);
      }
    );
    stream.end(fileBuffer);
  });
};

// Upload single image (Multipart)
router.post('/', upload.single('image'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'Please upload an image file.'
      });
    }

    if (isCloudinaryActive()) {
      // Permanent Cloud Storage on Cloudinary
      const result = await uploadStreamToCloudinary(req.file.buffer, req.file.originalname);
      return res.status(200).json({
        success: true,
        message: 'Image uploaded to cloud storage successfully.',
        data: {
          url: result.secure_url,
          public_id: result.public_id,
          format: result.format,
          bytes: result.bytes
        }
      });
    }

    // Fallback: Local Disk Storage
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
    const ext = path.extname(req.file.originalname) || '.jpg';
    const filename = `${req.file.fieldname}-${uniqueSuffix}${ext}`;
    const filePath = path.join(uploadDir, filename);

    fs.writeFileSync(filePath, req.file.buffer);

    return res.status(200).json({
      success: true,
      message: 'Image saved locally (Cloudinary API Secret not set).',
      data: {
        url: `/uploads/${filename}`,
        filename: filename,
        size: req.file.size
      }
    });
  } catch (error) {
    console.error('Upload Error:', error);
    res.status(500).json({
      success: false,
      message: 'Image upload failed: ' + error.message
    });
  }
});

// Upload base64 image (Mobile camera / Web canvas)
router.post('/base64', async (req, res) => {
  try {
    const { base64Data, filename = 'image.jpg' } = req.body;
    if (!base64Data) {
      return res.status(400).json({
        success: false,
        message: 'No base64 data provided.'
      });
    }

    if (isCloudinaryActive()) {
      // Direct base64 upload to Cloudinary
      const result = await cloudinary.uploader.upload(base64Data, {
        folder: 'farmer_choice',
        resource_type: 'image'
      });

      return res.status(200).json({
        success: true,
        message: 'Base64 image uploaded to cloud storage successfully.',
        data: {
          url: result.secure_url,
          public_id: result.public_id,
          format: result.format,
          bytes: result.bytes
        }
      });
    }

    // Fallback: Local Disk Storage
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

    return res.status(200).json({
      success: true,
      message: 'Base64 image saved locally (Cloudinary API Secret not set).',
      data: {
        url: `/uploads/${uniqueName}`,
        filename: uniqueName
      }
    });
  } catch (error) {
    console.error('Base64 Upload Error:', error);
    res.status(500).json({
      success: false,
      message: 'Base64 upload failed: ' + error.message
    });
  }
});

module.exports = router;
