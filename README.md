# Farmer Choice 🌱
> *"From Farmer to Your Home"*

Farmer Choice is a **FREE direct farmer-to-customer vegetable marketplace** that eliminates middlemen and allows customers to discover, compare, chat with, and buy directly from farmers.

---

## 🌟 Architecture Highlights

- **ONE Flutter Application (`mobile/`)**: Single unified APK & iOS build for both **CUSTOMER** and **FARMER** roles. Post-login role routing dynamically activates the appropriate interface and feature modules.
- **ZERO Payment Processing**: Pure direct negotiation platform. Zero transaction fees, zero listing fees, zero subscriptions. Deals use reference values, with payments settled directly (Cash, UPI, Direct Transfer) between customer and farmer.
- **Vegetable-Centric Marketplace**: Dynamic MongoDB catalog focusing on farm-fresh vegetables (Tomato, Small Onion, Palak Keerai, Ladies Finger, Carrot, etc.).
- **Backend-Enforced Verified Reviews**: Reviews are strictly locked until a deal reaches `COMPLETED` status, guaranteeing 100% authentic ratings.
- **Real-Time Communication**: Socket.IO powered messaging with typing indicators, online status, and contextual deal linking.
- **React + TypeScript Admin Panel (`admin/`)**: Complete operations center for farmer verification, vegetable/featured listing moderation, deal monitoring, safety report investigation, and platform analytics.

---

## 📁 Repository Structure

```
FarmerChoice/
├── backend/                  # Node.js + Express + MongoDB + Socket.IO REST API
│   ├── src/
│   │   ├── config/           # Database & environment configurations
│   │   ├── constants/        # Role & Deal state definitions
│   │   ├── controllers/      # REST endpoint controllers
│   │   ├── middlewares/      # JWT, Role Guards, Rate Limiters
│   │   ├── models/           # Mongoose schemas (User, Deal, Review, Vegetable, etc.)
│   │   ├── routes/           # Express API routers (/api/v1/*)
│   │   ├── sockets/          # Socket.io chat server
│   │   └── seed/             # Realistic Tamil Nadu agricultural seed data
│   └── package.json
│
├── mobile/                   # ONE Unified Flutter Mobile Application
│   ├── lib/
│   │   ├── core/             # Theme, Storage, API Client, Socket Service, Models
│   │   └── features/
│   │       ├── auth/         # Login, Role Selection, Customer/Farmer Registration
│   │       ├── customer/     # Home, Search, Comparison, Detail, Deals, Chat, Reviews
│   │       └── farmer/       # Dashboard, Inventory, Prices, Deals, Inquiries, Profile
│   └── pubspec.yaml
│
└── admin/                    # React 18 + TypeScript + Vite Admin Control Panel
    ├── src/
    │   ├── components/       # Layout, Sidebar, Navbar, Stat cards
    │   ├── pages/            # Farmers, Customers, Vegetables, Deals, Reviews, Reports
    │   └── services/         # Axios Admin API client
    └── package.json
```

---

## 🚀 Getting Started

### 1. Backend Service
```bash
cd backend
npm install
npm run seed     # Populate realistic Tamil Nadu farmers & vegetables
npm run dev      # Runs on http://localhost:5000
```

#### Demo Credentials (from seed):
- **Super Admin**: `admin@farmerchoice.in` / `password123`
- **Farmer (Ramesh Kumar)**: `9840123451` / `password123`
- **Customer (Karthik S)**: `9876543210` / `password123`

---

### 2. Admin Control Panel
```bash
cd admin
npm install
npm run dev      # Runs on http://localhost:5173
```

---

### 3. Flutter Mobile Application
```bash
cd mobile
flutter pub get
flutter run      # Run on Web, Android, or iOS
```
