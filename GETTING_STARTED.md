# 🚀 Getting Started - Ace Mall Staff Management System

Complete guide to set up and run the full-stack staff management application.

## 📋 Prerequisites

### Required Software:
- **PostgreSQL 14+** - Database
- **Go 1.21+** - Backend
- **Flutter 3.6+** - Mobile app
- **Git** - Version control

### Installation:

**macOS:**
```bash
# Install PostgreSQL
brew install postgresql@14
brew services start postgresql@14

# Install Go
brew install go

# Install Flutter
brew install --cask flutter
```

**Ubuntu/Linux:**
```bash
# Install PostgreSQL
sudo apt-get update
sudo apt-get install postgresql-14

# Install Go
wget https://go.dev/dl/go1.21.0.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.21.0.linux-amd64.tar.gz

# Install Flutter
snap install flutter --classic
```

## 🗄️ Database Setup

### Step 1: Start PostgreSQL

**macOS:**
```bash
brew services start postgresql@14
```

**Linux:**
```bash
sudo systemctl start postgresql
```

### Step 2: Create Database User (if needed)

```bash
# Access PostgreSQL
psql postgres

# Create user
CREATE USER postgres WITH PASSWORD 'postgres';
ALTER USER postgres WITH SUPERUSER;

# Exit
\q
```

### Step 3: Run Setup Script

```bash
cd backend
./setup.sh
```

The script will:
- ✅ Create database `ace_mall_db`
- ✅ Run schema (tables, indexes, default data)
- ✅ Insert 60+ roles
- ✅ Insert 13 branches
- ✅ Insert 6 departments
- ✅ Install Go dependencies

## 🔧 Backend Setup

### Step 1: Configure Environment

```bash
cd backend

# Edit .env file with your settings
nano .env
```

**Important settings:**
```env
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=your_password
DB_NAME=ace_mall_db

PORT=8080
JWT_SECRET=your_super_secret_key_change_this
```

### Step 2: Start Backend Server

```bash
go run main.go
```

You should see:
```
✅ Database connected successfully
🚀 Server starting on port 8080
```

### Step 3: Test API

```bash
# Health check
curl http://localhost:8080/health

# Get branches
curl http://localhost:8080/api/v1/data/branches

# Get roles
curl http://localhost:8080/api/v1/data/roles
```

## 📱 Flutter App Setup

### Step 1: Install Dependencies

```bash
cd ace_mall_app
flutter pub get
```

### Step 2: Configure API URL

Edit `lib/services/api_service.dart`:

```dart
// For iOS Simulator
static const String baseUrl = 'http://localhost:8080/api/v1';

// For Android Emulator
static const String baseUrl = 'http://10.0.2.2:8080/api/v1';

// For Physical Device (use your computer's IP)
static const String baseUrl = 'http://192.168.1.x:8080/api/v1';
```

### Step 3: Run Flutter App

```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d chrome        # Web
flutter run -d macos         # macOS
flutter run -d ios           # iOS Simulator
flutter run -d android       # Android Emulator
```

## 🎯 Testing the Application

### 1. Test Intro Page
- App should show green animated splash screen
- Auto-navigates to sign-in after 3 seconds

### 2. Test Sign-In Page
- White background with green cart icon
- Email and password fields
- "Forgot Password?" links

### 3. Test Staff Type Selection (After Sign-in)
- Two cards: Administrative Staff vs General Staff
- Tap to select staff type

### 4. Test Role Selection
- Search bar to filter roles
- List of roles based on staff type
- Radio button selection

### 5. Test Branch Selection
- Grid of 13 branches
- Tap to select branch
- Continue button enabled after selection

### 6. Test API Integration
```bash
# Test login endpoint
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password"}'

# Test branches endpoint
curl http://localhost:8080/api/v1/data/branches

# Test roles endpoint
curl http://localhost:8080/api/v1/data/roles?category=admin
```

## 📊 Database Verification

### Check Created Data:

```bash
# Connect to database
psql -U postgres -d ace_mall_db

# Check branches
SELECT * FROM branches;

# Check departments
SELECT * FROM departments;

# Check roles count
SELECT category, COUNT(*) FROM roles GROUP BY category;

# Exit
\q
```

Expected results:
- **13 branches** (Oluyole, Bodija, Akobo, etc.)
- **6 departments** (SuperMarket, Eatery, Lounge, etc.)
- **60+ roles** (4 senior_admin, 30+ admin, 30+ general)

## 🔍 Troubleshooting

### Backend Issues:

**Database Connection Error:**
```bash
# Check PostgreSQL is running
brew services list | grep postgresql  # macOS
systemctl status postgresql           # Linux

# Check credentials in .env file
cat backend/.env
```

**Port Already in Use:**
```bash
# Find process using port 8080
lsof -i :8080

# Kill process
kill -9 <PID>
```

**Go Dependencies Error:**
```bash
cd backend
go mod tidy
go mod download
```

### Flutter Issues:

**Dependencies Error:**
```bash
cd ace_mall_app
flutter clean
flutter pub get
```

**Device Not Found:**
```bash
# Check available devices
flutter devices

# For iOS Simulator
open -a Simulator

# For Android Emulator
flutter emulators --launch <emulator_id>
```

**API Connection Error:**
- Check backend is running on port 8080
- Verify API URL in `api_service.dart`
- For Android emulator, use `10.0.2.2` instead of `localhost`
- For physical device, use your computer's IP address

## 📁 Project Structure

```
Ace App/
├── backend/                    # Go backend
│   ├── config/                # Database config
│   ├── database/              # SQL schemas
│   ├── handlers/              # API handlers
│   ├── middleware/            # Auth middleware
│   ├── models/                # Data models
│   ├── utils/                 # Utilities
│   ├── main.go                # Entry point
│   ├── .env                   # Configuration
│   └── setup.sh               # Setup script
│
├── ace_mall_app/              # Flutter app
│   ├── lib/
│   │   ├── models/           # Data models
│   │   ├── pages/            # UI pages
│   │   ├── services/         # API service
│   │   └── main.dart         # Entry point
│   └── pubspec.yaml          # Dependencies
│
├── GETTING_STARTED.md         # This file
├── IMPLEMENTATION_PLAN.md     # Development plan
└── README.md                  # Project overview
```

## 🎨 Design System

### Colors:
- **Primary Green**: `#4CAF50`
- **Light Green**: `#66BB6A`
- **Dark Green**: `#2E7D32`
- **White**: `#FFFFFF`
- **Grey**: `#9E9E9E`

### Typography:
- **Font**: Inter (Google Fonts)
- **Title**: 28-38px, Bold (w700)
- **Body**: 14-16px, Regular (w400)
- **Button**: 16px, SemiBold (w600)

## 🔐 Default Test Credentials

**Note:** No default users exist yet. HR must create staff profiles.

To create an HR user manually:
```sql
-- Connect to database
psql -U postgres -d ace_mall_db

-- Get HR role ID
SELECT id FROM roles WHERE name = 'Human Resource';

-- Insert HR user (replace <role_id> with actual ID)
INSERT INTO users (email, password_hash, full_name, role_id, date_joined, is_active)
VALUES (
  'hr@acemarket.com',
  '$2a$10$...', -- Use bcrypt to hash 'password'
  'HR Admin',
  '<role_id>',
  CURRENT_DATE,
  true
);
```

## 📞 Support

For issues or questions:
1. Check the troubleshooting section above
2. Review backend logs in terminal
3. Check Flutter console for errors
4. Verify database connection and data

## 🎯 Next Steps

After successful setup:

1. **Create HR User** (manually in database)
2. **Login as HR** to test authentication
3. **Create Staff Profiles** using the app
4. **Test Role-Based Access** with different user types
5. **Implement Remaining Features**:
   - Department selection page
   - Profile creation forms
   - Document upload
   - HR dashboard
   - Floor manager features

## 📚 Additional Resources

- **Backend API Docs**: `/backend/README.md`
- **Implementation Plan**: `/IMPLEMENTATION_PLAN.md`
- **Database Schema**: `/backend/database/schema.sql`
- **Roles Data**: `/backend/database/roles_data.sql`

---

**Happy Coding! 🚀**
