# iOS Build Setup for Ace SuperMarket Staff App

## Prerequisites

- macOS with Xcode installed
- Apple Developer Account ($99/year)
- Physical iOS device or simulator

---

## Step 1: Configure Bundle Identifier

1. Open Xcode workspace:
```bash
cd ios
open Runner.xcworkspace
```

2. In Xcode:
   - Select **Runner** project in left sidebar
   - Select **Runner** target
   - Go to **Signing & Capabilities** tab
   - Change **Bundle Identifier** from `com.example.aceMallApp` to `com.acesupermarket.staff`

## Step 2: Configure Code Signing

### Option A: Automatic Signing (Recommended)

1. In **Signing & Capabilities**:
   - Check **Automatically manage signing**
   - Select your **Team** from dropdown
   - Xcode will automatically create provisioning profiles

### Option B: Manual Signing

1. Go to [Apple Developer Portal](https://developer.apple.com/account/)
2. Create App ID: `com.acesupermarket.staff`
3. Create Provisioning Profile for App Store distribution
4. Download and install profile
5. In Xcode, select the profile manually

## Step 3: Update Info.plist

The app name and version are already configured in `ios/Runner/Info.plist`:

```xml
<key>CFBundleDisplayName</key>
<string>Ace SuperMarket</string>
<key>CFBundleShortVersionString</key>
<string>1.0.0</string>
<key>CFBundleVersion</key>
<string>1</string>
```

## Step 4: Build IPA

```bash
# From project root
flutter build ipa --release
```

**Output:** `build/ios/ipa/ace_mall_app.ipa`

## Step 5: Upload to TestFlight

### Using Xcode (Easiest)

1. In Xcode, go to **Product** → **Archive**
2. Once archive completes, **Organizer** window opens
3. Select your archive
4. Click **Distribute App**
5. Select **App Store Connect**
6. Click **Upload**
7. Follow prompts to complete upload

### Using Transporter App

1. Download **Transporter** from Mac App Store
2. Open Transporter
3. Sign in with Apple ID
4. Drag and drop `ace_mall_app.ipa`
5. Click **Deliver**

### Using Command Line

```bash
xcrun altool --upload-app \
  --type ios \
  --file build/ios/ipa/ace_mall_app.ipa \
  --username YOUR_APPLE_ID \
  --password YOUR_APP_SPECIFIC_PASSWORD
```

## Step 6: Configure TestFlight in App Store Connect

1. Go to [App Store Connect](https://appstoreconnect.apple.com/)
2. Select your app
3. Go to **TestFlight** tab
4. Wait for build to process (10-30 minutes)
5. Add internal testers
6. Submit for external testing (requires review)

---

## Troubleshooting

**"No profiles found" error:**
- Enable automatic signing in Xcode
- Or create provisioning profile manually in Developer Portal

**"Signing certificate not found":**
- Go to Xcode → Preferences → Accounts
- Select your Apple ID
- Click "Manage Certificates"
- Create "Apple Distribution" certificate

**Build fails with code signing error:**
- Clean build folder: Product → Clean Build Folder
- Delete derived data: ~/Library/Developer/Xcode/DerivedData
- Restart Xcode

**IPA upload fails:**
- Ensure you're using App Store distribution profile
- Check bundle identifier matches App Store Connect
- Verify app version/build number is unique

---

## Quick Commands

**Build for simulator:**
```bash
flutter build ios --simulator
```

**Build for device (debug):**
```bash
flutter build ios --debug
```

**Build for TestFlight:**
```bash
flutter build ipa --release
```

---

## Important Notes

- ✅ Bundle ID: `com.acesupermarket.staff`
- ✅ Version: `1.0.0`
- ✅ Build: `1`
- ⚠️ Requires Apple Developer Account
- ⚠️ TestFlight external testing requires App Review
- ⚠️ First upload may take 24-48 hours for review

---

**For now, use the Android APK for testing. iOS build requires Apple Developer Account setup.**
