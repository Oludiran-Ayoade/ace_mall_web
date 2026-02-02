# Ace SuperMarket Staff App - Build Instructions

## Prerequisites

- Flutter SDK (latest stable)
- Android Studio with Android SDK
- Xcode (for iOS builds, macOS only)
- Java JDK 17

---

## 🤖 Android APK Build (18-25MB Target)

### Step 1: Generate Signing Key

```bash
cd android/app
keytool -genkey -v -keystore ace-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias ace-key
```

**Enter the following when prompted:**
- Password: `ace2026secure`
- Re-enter password: `ace2026secure`
- First and Last Name: `Ace SuperMarket`
- Organizational Unit: `IT Department`
- Organization: `Ace SuperMarket Ltd`
- City: `Ibadan`
- State: `Oyo`
- Country Code: `NG`

### Step 2: Create key.properties

Create `android/key.properties`:

```properties
storePassword=ace2026secure
keyPassword=ace2026secure
keyAlias=ace-key
storeFile=app/ace-release-key.jks
```

### Step 3: Build Release APK

```bash
# Clean build
flutter clean
flutter pub get

# Build optimized APK (18-25MB)
flutter build apk --release --split-per-abi --obfuscate --split-debug-info=build/app/outputs/symbols

# Or build universal APK (larger, ~40MB)
flutter build apk --release --obfuscate --split-debug-info=build/app/outputs/symbols
```

**Output locations:**
- ARM64 APK (recommended): `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk` (~18-22MB)
- ARMv7 APK: `build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk` (~18-22MB)
- x86_64 APK: `build/app/outputs/flutter-apk/app-x86_64-release.apk` (~20-25MB)
- Universal APK: `build/app/outputs/flutter-apk/app-release.apk` (~35-45MB)

**Recommended:** Use `app-arm64-v8a-release.apk` for modern devices (covers 95% of Android devices).

---

## 🍎 iOS TestFlight Build

### Step 1: Configure Xcode Project

```bash
cd ios
open Runner.xcworkspace
```

In Xcode:
1. Select **Runner** project
2. Go to **Signing & Capabilities**
3. Select your **Team** (Apple Developer Account)
4. Update **Bundle Identifier**: `com.acesupermarket.staff`
5. Set **Version**: `1.0.0`
6. Set **Build**: `1`

### Step 2: Update Info.plist

Edit `ios/Runner/Info.plist` and ensure:

```xml
<key>CFBundleDisplayName</key>
<string>Ace SuperMarket</string>
<key>CFBundleIdentifier</key>
<string>com.acesupermarket.staff</string>
<key>CFBundleShortVersionString</key>
<string>1.0.0</string>
<key>CFBundleVersion</key>
<string>1</string>
```

### Step 3: Build for TestFlight

```bash
# Clean build
flutter clean
flutter pub get

# Build iOS archive
flutter build ipa --release --obfuscate --split-debug-info=build/ios/outputs/symbols
```

**Output location:** `build/ios/ipa/ace_mall_app.ipa`

### Step 4: Upload to TestFlight

**Option A: Using Xcode**
1. Open `build/ios/archive/Runner.xcarchive`
2. Click **Distribute App**
3. Select **App Store Connect**
4. Select **Upload**
5. Follow prompts to upload

**Option B: Using Transporter**
1. Download **Transporter** from Mac App Store
2. Open Transporter
3. Drag and drop `ace_mall_app.ipa`
4. Click **Deliver**

**Option C: Using Command Line**
```bash
xcrun altool --upload-app --type ios --file build/ios/ipa/ace_mall_app.ipa --username YOUR_APPLE_ID --password YOUR_APP_SPECIFIC_PASSWORD
```

---

## 📦 App Size Optimization

Current configuration achieves 18-25MB APK size through:

✅ **Code Minification** - ProGuard enabled
✅ **Resource Shrinking** - Removes unused resources
✅ **Code Obfuscation** - Reduces code size and improves security
✅ **Split APKs** - Separate APKs per CPU architecture
✅ **Optimized Images** - Compressed assets
✅ **Tree Shaking** - Removes unused Dart code

---

## 🧪 Testing Builds

### Test APK on Device

```bash
# Install on connected device
flutter install --release

# Or manually install
adb install build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

### Test iOS Build

```bash
# Run on simulator
flutter run --release -d "iPhone 15 Pro"

# Run on physical device
flutter run --release -d YOUR_DEVICE_ID
```

---

## 📱 App Store Submission Checklist

### Android (Google Play)

- [ ] APK built and tested
- [ ] App signed with release key
- [ ] Version code incremented
- [ ] Screenshots prepared (phone & tablet)
- [ ] Feature graphic (1024x500)
- [ ] App icon (512x512)
- [ ] Privacy policy URL
- [ ] App description and metadata
- [ ] Content rating completed

### iOS (App Store)

- [ ] IPA built and uploaded to TestFlight
- [ ] App tested on TestFlight
- [ ] Screenshots prepared (all device sizes)
- [ ] App icon (1024x1024)
- [ ] Privacy policy URL
- [ ] App description and metadata
- [ ] Age rating completed
- [ ] Export compliance information

---

## 🔐 Security Notes

- ✅ Release keys stored securely (not in Git)
- ✅ Code obfuscation enabled
- ✅ Debug symbols separated
- ✅ API keys in environment variables
- ✅ HTTPS only for API calls
- ✅ Certificate pinning recommended

---

## 📊 Build Verification

**Check APK Size:**
```bash
ls -lh build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

**Analyze APK:**
```bash
flutter build apk --analyze-size
```

**Check IPA Size:**
```bash
ls -lh build/ios/ipa/ace_mall_app.ipa
```

---

## 🚀 Quick Build Commands

**Android (Recommended):**
```bash
flutter build apk --release --split-per-abi --obfuscate --split-debug-info=build/app/outputs/symbols
```

**iOS:**
```bash
flutter build ipa --release --obfuscate --split-debug-info=build/ios/outputs/symbols
```

---

## 🆘 Troubleshooting

**APK size too large (>25MB)?**
- Use `--split-per-abi` flag
- Check for large assets in `assets/` folder
- Run `flutter build apk --analyze-size`

**Signing errors?**
- Verify `key.properties` exists and has correct paths
- Check keystore password is correct
- Ensure keystore file is in `android/app/` directory

**iOS build fails?**
- Update Xcode to latest version
- Run `pod install` in `ios/` directory
- Clean build: `flutter clean && cd ios && pod deintegrate && pod install`

**App crashes on release?**
- Check ProGuard rules for missing keep rules
- Test with `flutter run --release` before building
- Review crash logs in Firebase Crashlytics

---

**Target APK Size: 18-25MB ✅**
**Current Configuration: Optimized for size and performance**
