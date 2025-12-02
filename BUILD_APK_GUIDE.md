# Building APK for DS CRM App

## Current Status
❌ **Android SDK Not Installed** - Cannot build APK without Android SDK

## Prerequisites for Building APK

To build an Android APK, you need to install:

### 1. **Android Studio** (Recommended)
Download from: https://developer.android.com/studio

Android Studio includes:
- Android SDK
- Android SDK Platform-Tools
- Android SDK Build-Tools
- Android Emulator

### 2. **Java Development Kit (JDK)**
- JDK 17 or higher is required
- Usually bundled with Android Studio

## Installation Steps

### Step 1: Install Android Studio
1. Download Android Studio from https://developer.android.com/studio
2. Run the installer
3. Follow the setup wizard
4. Install the Android SDK (default location: `C:\Users\<YourName>\AppData\Local\Android\Sdk`)

### Step 2: Set Environment Variables
Add these to your system environment variables:

```powershell
# Set ANDROID_HOME
$env:ANDROID_HOME = "C:\Users\$env:USERNAME\AppData\Local\Android\Sdk"
[System.Environment]::SetEnvironmentVariable('ANDROID_HOME', $env:ANDROID_HOME, 'User')

# Add to PATH
$androidPath = "$env:ANDROID_HOME\platform-tools;$env:ANDROID_HOME\cmdline-tools\latest\bin"
$currentPath = [System.Environment]::GetEnvironmentVariable('Path', 'User')
[System.Environment]::SetEnvironmentVariable('Path', "$currentPath;$androidPath", 'User')
```

### Step 3: Accept Android Licenses
```bash
C:\src\flutter\bin\flutter.bat doctor --android-licenses
```

### Step 4: Verify Setup
```bash
C:\src\flutter\bin\flutter.bat doctor
```

You should see:
```
[✓] Android toolchain - develop for Android devices
```

## Building the APK

Once Android SDK is installed, run:

### Debug APK (Faster, larger file)
```bash
C:\src\flutter\bin\flutter.bat build apk --debug
```

### Release APK (Optimized, smaller file) ⭐ **Recommended**
```bash
C:\src\flutter\bin\flutter.bat build apk --release
```

### Split APKs by Architecture (Smaller individual files)
```bash
C:\src\flutter\bin\flutter.bat build apk --split-per-abi
```

This creates 3 APKs:
- `app-armeabi-v7a-release.apk` (32-bit ARM)
- `app-arm64-v8a-release.apk` (64-bit ARM) ⭐ **Most common**
- `app-x86_64-release.apk` (64-bit x86)

## APK Output Location

After successful build, the APK will be located at:

```
c:\Users\Bhuvanesh H\Downloads\WorkFlow-CRM(1.18.6)\DS-CRM App\build\app\outputs\flutter-apk\
```

Files:
- **Release APK**: `app-release.apk` (Universal APK, ~20-40 MB)
- **Split APKs**: `app-arm64-v8a-release.apk`, etc. (~15-25 MB each)

## Alternative: Use GitHub Actions (No Local Android SDK Required)

If you don't want to install Android SDK locally, you can use GitHub Actions to build the APK in the cloud:

### 1. Create `.github/workflows/build-apk.yml`:

```yaml
name: Build APK

on:
  push:
    branches: [ main ]
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - uses: actions/setup-java@v3
      with:
        distribution: 'zulu'
        java-version: '17'
    
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.10.1'
        channel: 'stable'
    
    - name: Get dependencies
      run: flutter pub get
    
    - name: Build APK
      run: flutter build apk --release --split-per-abi
    
    - name: Upload APK
      uses: actions/upload-artifact@v3
      with:
        name: release-apk
        path: build/app/outputs/flutter-apk/*.apk
```

### 2. Push to GitHub and download the built APK from Actions tab

## App Configuration

The app is already configured for Android:

✅ **Internet Permission** - Added to AndroidManifest.xml
✅ **MinSDK 21** - Android 5.0+ (Covers 99%+ devices)
✅ **WebView Support** - Uses `webview_flutter` package
✅ **Offline Support** - Built-in offline detection and fallback UI
✅ **Platform Detection** - Automatically uses WebView on Android, iframe on Web

## Testing the APK

### On Physical Device:
1. Enable "Developer Options" on your Android device
2. Enable "USB Debugging"
3. Connect device via USB
4. Run: `C:\src\flutter\bin\flutter.bat install`

### On Emulator:
1. Open Android Studio
2. Create an AVD (Android Virtual Device)
3. Start the emulator
4. Run: `C:\src\flutter\bin\flutter.bat install`

## Quick Start (After Android SDK Installation)

```bash
# Navigate to project
cd "c:\Users\Bhuvanesh H\Downloads\WorkFlow-CRM(1.18.6)\DS-CRM App"

# Build release APK
C:\src\flutter\bin\flutter.bat build apk --release --split-per-abi

# APK will be at:
# build\app\outputs\flutter-apk\app-arm64-v8a-release.apk
```

## File Sizes (Approximate)

- **Universal APK**: 35-45 MB
- **ARM64 APK**: 18-25 MB (Most devices)
- **ARMv7 APK**: 18-25 MB (Older devices)
- **x86_64 APK**: 20-28 MB (Emulators/tablets)

## Next Steps

1. ✅ Install Android Studio
2. ✅ Set up Android SDK
3. ✅ Accept licenses: `flutter doctor --android-licenses`
4. ✅ Build APK: `flutter build apk --release`
5. ✅ Find APK in `build\app\outputs\flutter-apk\`
6. ✅ Install on device or share the APK file

## Support

If you encounter issues:
1. Run `flutter doctor -v` for detailed diagnostics
2. Check Flutter documentation: https://docs.flutter.dev/deployment/android
3. Ensure all licenses are accepted
4. Verify ANDROID_HOME is set correctly
