#!/bin/bash

# 🚀 Ace Mall App - Quick Start Script
# This script helps you set up and run the application

set -e  # Exit on error

echo "🎯 Ace Mall App - Quick Start"
echo "================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if .env exists
if [ ! -f "backend/.env" ]; then
    echo -e "${YELLOW}⚠️  .env file not found!${NC}"
    echo ""
    echo "Creating .env from example..."
    cp backend/.env.example backend/.env
    echo -e "${GREEN}✅ Created backend/.env${NC}"
    echo ""
    echo -e "${YELLOW}📝 IMPORTANT: Edit backend/.env with your credentials:${NC}"
    echo "   - DB_PASSWORD (your PostgreSQL password)"
    echo "   - JWT_SECRET (generate a strong secret)"
    echo "   - CLOUDINARY credentials (if you have them)"
    echo ""
    echo "Press Enter after you've edited the .env file..."
    read
fi

# Check PostgreSQL connection
echo "🔍 Checking PostgreSQL connection..."
if command -v psql &> /dev/null; then
    if psql -U postgres -d ace_mall_db -c "SELECT 1" &> /dev/null; then
        echo -e "${GREEN}✅ PostgreSQL connection successful${NC}"
    else
        echo -e "${RED}❌ Cannot connect to PostgreSQL${NC}"
        echo "Please ensure:"
        echo "  1. PostgreSQL is running"
        echo "  2. Database 'ace_mall_db' exists"
        echo "  3. Credentials in .env are correct"
        exit 1
    fi
else
    echo -e "${YELLOW}⚠️  psql not found - skipping database check${NC}"
fi

# Check if migration has been run
echo ""
echo "🔍 Checking database migration..."
if psql -U postgres -d ace_mall_db -c "\dt notifications" &> /dev/null; then
    echo -e "${GREEN}✅ Migration already completed${NC}"
else
    echo -e "${YELLOW}⚠️  Migration not run yet${NC}"
    echo ""
    echo "Would you like to run the migration now? (y/n)"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        echo "Running migration..."
        psql -U postgres -d ace_mall_db -f backend/database/migrations/006_notifications_and_shift_templates.sql
        echo -e "${GREEN}✅ Migration completed${NC}"
    else
        echo -e "${YELLOW}⚠️  Skipping migration - remember to run it manually!${NC}"
    fi
fi

# Check Go installation
echo ""
echo "🔍 Checking Go installation..."
if command -v go &> /dev/null; then
    GO_VERSION=$(go version)
    echo -e "${GREEN}✅ Go installed: $GO_VERSION${NC}"
else
    echo -e "${RED}❌ Go not found${NC}"
    echo "Please install Go from https://golang.org/dl/"
    exit 1
fi

# Check Flutter installation
echo ""
echo "🔍 Checking Flutter installation..."
if command -v flutter &> /dev/null; then
    FLUTTER_VERSION=$(flutter --version | head -n 1)
    echo -e "${GREEN}✅ Flutter installed: $FLUTTER_VERSION${NC}"
else
    echo -e "${YELLOW}⚠️  Flutter not found${NC}"
    echo "Install Flutter from https://flutter.dev/docs/get-started/install"
fi

# Start backend
echo ""
echo "🚀 Starting backend server..."
echo "================================"
cd backend

# Install Go dependencies
echo "Installing Go dependencies..."
go mod tidy

# Start server in background
echo "Starting server on port 8080..."
go run main.go &
BACKEND_PID=$!

# Wait for server to start
echo "Waiting for server to start..."
sleep 3

# Test health endpoint
if curl -s http://localhost:8080/health > /dev/null; then
    echo -e "${GREEN}✅ Backend server running on http://localhost:8080${NC}"
else
    echo -e "${RED}❌ Backend server failed to start${NC}"
    kill $BACKEND_PID 2>/dev/null
    exit 1
fi

cd ..

# Start frontend
echo ""
echo "🎨 Starting Flutter app..."
echo "================================"
cd ace_mall_app

echo "Getting Flutter dependencies..."
flutter pub get

echo ""
echo "Select platform to run:"
echo "1) Web (Chrome)"
echo "2) macOS Desktop"
echo "3) iOS Simulator"
echo "4) Skip frontend"
read -p "Enter choice (1-4): " choice

case $choice in
    1)
        echo "Starting on Chrome..."
        flutter run -d chrome
        ;;
    2)
        echo "Starting on macOS..."
        flutter run -d macos
        ;;
    3)
        echo "Starting on iOS Simulator..."
        flutter run -d ios
        ;;
    4)
        echo "Skipping frontend..."
        ;;
    *)
        echo "Invalid choice. Skipping frontend..."
        ;;
esac

cd ..

# Cleanup function
cleanup() {
    echo ""
    echo "🛑 Shutting down..."
    kill $BACKEND_PID 2>/dev/null
    echo "Goodbye!"
}

trap cleanup EXIT

echo ""
echo -e "${GREEN}✅ Setup complete!${NC}"
echo ""
echo "📚 Useful commands:"
echo "   - Backend logs: Check terminal where script is running"
echo "   - Test API: curl http://localhost:8080/health"
echo "   - Stop server: Press Ctrl+C"
echo ""
echo "📖 Documentation:"
echo "   - COMPLETE_SETUP_GUIDE.md - Full setup instructions"
echo "   - DEPLOYMENT_CHECKLIST.md - Deployment steps"
echo "   - PRODUCTION_IMPLEMENTATION_GUIDE.md - Implementation details"
echo ""

# Keep script running
wait
