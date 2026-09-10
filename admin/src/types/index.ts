export type UserRole = 'CUSTOMER' | 'FARMER' | 'ADMIN' | 'SUPER_ADMIN';

export interface User {
  _id: string;
  name: string;
  phone: string;
  email?: string;
  role: UserRole;
  profileImage?: string;
  status: 'ACTIVE' | 'SUSPENDED';
  isVerified: boolean;
  createdAt: string;
  lastLoginAt?: string;
}

export interface FarmerProfile {
  _id: string;
  userId: User;
  farmName: string;
  village: string;
  taluk?: string;
  district: string;
  state: string;
  farmAddress: string;
  aboutMe: string;
  farmingExperienceYears?: number;
  verificationStatus: 'PENDING' | 'VERIFIED' | 'REJECTED';
  rating: number;
  totalReviews: number;
  completedDealsCount: number;
  isOrganicCertified: boolean;
  badges: string[];
  farmPhotos?: string[];
  createdAt: string;
}

export interface CustomerProfile {
  _id: string;
  userId: User;
  villageOrTown: string;
  district: string;
  state: string;
  defaultDeliveryAddress?: string;
  totalDealsCompleted: number;
  createdAt: string;
}

export interface Vegetable {
  _id: string;
  farmerId: User;
  farmerProfileId: FarmerProfile;
  name: string;
  tamilName?: string;
  category: 'Leafy' | 'Root' | 'Vegetable' | 'Other';
  images: string[];
  description: string;
  price: number;
  priceUnit: string;
  availableQuantity: number;
  availabilityStatus: 'AVAILABLE_NOW' | 'LIMITED_STOCK' | 'OUT_OF_STOCK' | 'AVAILABLE_FROM_DATE';
  featuredStatus: 'NONE' | 'REQUESTED' | 'APPROVED' | 'REJECTED';
  featuredUntil?: string;
  status: 'ACTIVE' | 'HIDDEN' | 'SUSPENDED';
  viewCount: number;
  createdAt: string;
}

export interface Deal {
  _id: string;
  dealNumber: string;
  customerId: User;
  farmerId: User;
  vegetableId: Vegetable;
  requestedQuantity: number;
  agreedQuantity: number;
  requestedPrice: number;
  agreedPrice: number;
  priceUnit: string;
  dealReferenceValue: number;
  deliveryMethod: 'PICKUP' | 'DELIVERY' | 'FARM_VISIT';
  deliveryAddress?: string;
  preferredDate: string;
  status: 'REQUESTED' | 'NEGOTIATING' | 'ACCEPTED' | 'READY' | 'COMPLETED' | 'CANCELLED' | 'DISPUTED';
  customerConfirmed: boolean;
  farmerConfirmed: boolean;
  completedAt?: string;
  createdAt: string;
}

export interface Review {
  _id: string;
  dealId: Deal;
  customerId: User;
  farmerId: User;
  vegetableId: Vegetable;
  rating: number;
  comment: string;
  isVerifiedDeal: boolean;
  status: 'PUBLISHED' | 'HIDDEN' | 'FLAGGED';
  farmerReply?: string;
  createdAt: string;
}

export interface Report {
  _id: string;
  reporterId: User;
  targetType: 'USER' | 'VEGETABLE' | 'REVIEW' | 'DEAL';
  targetId: string;
  reason: string;
  description: string;
  evidenceImages?: string[];
  status: 'PENDING' | 'INVESTIGATING' | 'ACTIONED' | 'DISMISSED';
  actionTaken?: string;
  createdAt: string;
}

export interface SupportTicket {
  _id: string;
  ticketNumber: string;
  userId: User;
  category: string;
  subject: string;
  description: string;
  status: 'OPEN' | 'IN_PROGRESS' | 'RESOLVED' | 'CLOSED';
  adminNotes?: string;
  createdAt: string;
}

export interface DashboardStats {
  totalFarmers: number;
  verifiedFarmers: number;
  pendingFarmers: number;
  totalCustomers: number;
  activeVegetables: number;
  activeDeals: number;
  completedDeals: number;
  cancelledDeals: number;
  pendingReports: number;
  openTickets: number;
}
