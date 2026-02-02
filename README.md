# Ace Mall Staff Management System - Web Version

A Next.js 14+ web application that replicates the Flutter mobile app for Ace Mall Staff Management System.

## Tech Stack

- **Framework**: Next.js 14+ (App Router)
- **Language**: TypeScript
- **Styling**: TailwindCSS
- **UI Components**: Custom components with shadcn/ui patterns
- **State Management**: React Context + TanStack Query
- **Forms**: React Hook Form + Zod validation
- **Icons**: Lucide React

## Getting Started

### Prerequisites

- Node.js 18+ installed
- npm or yarn package manager

### Installation

```bash
# Navigate to the project directory
cd ace_mall_web

# Install dependencies
npm install

# Start development server
npm run dev
```

The application will be available at `http://localhost:3000`

### Environment Variables

Create a `.env.local` file with the following variables:

```env
NEXT_PUBLIC_API_URL=https://ace-supermarket-backend.onrender.com/api/v1
NEXT_PUBLIC_CLOUDINARY_CLOUD_NAME=desk7uuna
NEXT_PUBLIC_CLOUDINARY_UPLOAD_PRESET=flutter_uploads
```

## Project Structure

```
src/
├── app/                    # Next.js App Router pages
│   ├── (auth)/            # Authentication pages (signin, forgot-password)
│   ├── (dashboard)/       # Dashboard pages with layout
│   │   ├── dashboard/     # Main dashboard
│   │   │   ├── staff/     # Staff management
│   │   │   ├── branches/  # Branch list
│   │   │   ├── departments/ # Department list
│   │   │   ├── rosters/   # Roster management
│   │   │   ├── reviews/   # Reviews & ratings
│   │   │   ├── notifications/ # User notifications
│   │   │   ├── profile/   # User profile
│   │   │   └── settings/  # User settings
│   │   └── layout.tsx     # Dashboard layout with sidebar
│   ├── layout.tsx         # Root layout
│   └── page.tsx           # Root page (redirects to signin)
├── components/
│   ├── ui/                # Reusable UI components (button, card, input, etc.)
│   ├── layout/            # Layout components (Sidebar, Header)
│   └── shared/            # Shared components (LoadingSpinner, etc.)
├── contexts/              # React contexts (Auth, Query)
├── hooks/                 # Custom React hooks
├── lib/                   # Utility functions and API client
│   ├── api.ts            # API client with all endpoints
│   ├── utils.ts          # Utility functions
│   └── constants.ts      # App constants
├── types/                 # TypeScript type definitions
└── styles/               # Global styles
```

## Features

### Authentication
- Sign in with email/password
- Forgot password flow (email → OTP → reset)
- JWT token management
- Role-based routing

### Dashboard
- Role-specific dashboards (CEO, HR, Branch Manager, Floor Manager, General Staff)
- Quick action cards
- Statistics overview

### Staff Management
- View all staff with filters (by branch, department)
- Staff profile with detailed information
- Add new staff (multi-step form)
- Edit staff profiles
- Promotion history
- Performance reviews

### Roster Management
- View weekly rosters
- Filter by branch and department
- Shift type color coding

### Reviews & Ratings
- View personal reviews
- Rating breakdown
- Review history

### Notifications
- Notification center
- Mark as read
- Delete notifications

### Settings
- Change password
- Update email
- Notification preferences

## API Integration

The web app connects to the existing Go backend at:
- **Production**: `https://ace-supermarket-backend.onrender.com/api/v1`
- **Local**: `http://localhost:8080/api/v1`

## Test Credentials

| Role | Email | Password |
|------|-------|----------|
| CEO | john@acemarket.com | password |
| HR | masterhr@acesupermarket.com | password |

## Design System

- **Primary Color**: Green (#4CAF50)
- **Dark Green**: #2E7D32
- **Font**: Inter (Google Fonts)
- **Border Radius**: 12px
- **Shadows**: Modern box-shadows

## Scripts

```bash
npm run dev      # Start development server
npm run build    # Build for production
npm run start    # Start production server
npm run lint     # Run ESLint
```

## Deployment

### Netlify

1. Connect GitHub repository
2. Build command: `npm run build`
3. Publish directory: `.next`
4. Add environment variables

## License

Private - Ace Mall Staff Management System
