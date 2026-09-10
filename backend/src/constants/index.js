const UserRoles = {
  CUSTOMER: 'CUSTOMER',
  FARMER: 'FARMER',
  ADMIN: 'ADMIN',
  SUPER_ADMIN: 'SUPER_ADMIN'
};

const UserStatus = {
  ACTIVE: 'ACTIVE',
  SUSPENDED: 'SUSPENDED',
  PENDING_VERIFICATION: 'PENDING_VERIFICATION'
};

const FarmerVerificationStatus = {
  PENDING: 'PENDING',
  VERIFIED: 'VERIFIED',
  REJECTED: 'REJECTED'
};

const VegetableCategories = {
  LEAFY: 'Leafy',
  ROOT: 'Root',
  VEGETABLE: 'Vegetable',
  OTHER: 'Other'
};

const AvailabilityStatus = {
  AVAILABLE_NOW: 'AVAILABLE_NOW',
  LIMITED_STOCK: 'LIMITED_STOCK',
  OUT_OF_STOCK: 'OUT_OF_STOCK',
  AVAILABLE_FROM_DATE: 'AVAILABLE_FROM_DATE'
};

const FeaturedStatus = {
  NONE: 'NONE',
  REQUESTED: 'REQUESTED',
  APPROVED: 'APPROVED',
  REJECTED: 'REJECTED'
};

const DealStatus = {
  REQUESTED: 'REQUESTED',
  NEGOTIATING: 'NEGOTIATING',
  ACCEPTED: 'ACCEPTED',
  READY: 'READY',
  COMPLETED: 'COMPLETED',
  CANCELLED: 'CANCELLED',
  DISPUTED: 'DISPUTED'
};

const DeliveryMethod = {
  PICKUP: 'PICKUP',
  DELIVERY: 'DELIVERY',
  FARM_VISIT: 'FARM_VISIT'
};

const MessageType = {
  TEXT: 'TEXT',
  IMAGE: 'IMAGE',
  DEAL_OFFER: 'DEAL_OFFER',
  SYSTEM: 'SYSTEM'
};

const SupportCategories = {
  ACCOUNT_ISSUE: 'Account Issue',
  FARMER_ISSUE: 'Farmer Issue',
  DEAL_ISSUE: 'Deal Issue',
  CHAT_ISSUE: 'Chat Issue',
  FAKE_PROFILE: 'Fake Profile',
  FAKE_REVIEW: 'Fake Review',
  SCAM: 'Scam',
  TECHNICAL: 'Technical',
  OTHER: 'Other'
};

const SupportStatus = {
  OPEN: 'OPEN',
  IN_PROGRESS: 'IN_PROGRESS',
  RESOLVED: 'RESOLVED',
  CLOSED: 'CLOSED'
};

const ReportReasons = {
  FAKE_FARMER: 'Fake Farmer',
  FAKE_CUSTOMER: 'Fake Customer',
  FAKE_PRODUCT: 'Fake Product',
  FAKE_REVIEW: 'Fake Review',
  SCAM: 'Scam',
  ABUSE: 'Abuse',
  SPAM: 'Spam',
  WRONG_PRICE: 'Wrong Price',
  OTHER: 'Other'
};

const ReportStatus = {
  PENDING: 'PENDING',
  INVESTIGATING: 'INVESTIGATING',
  ACTIONED: 'ACTIONED',
  DISMISSED: 'DISMISSED'
};

module.exports = {
  UserRoles,
  UserStatus,
  FarmerVerificationStatus,
  VegetableCategories,
  AvailabilityStatus,
  FeaturedStatus,
  DealStatus,
  DeliveryMethod,
  MessageType,
  SupportCategories,
  SupportStatus,
  ReportReasons,
  ReportStatus
};
