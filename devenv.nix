{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

let
  helpMsg = ''
    echo ""
    echo "🚀 React Native Development Environment"
    echo "======================================="
    echo ""
    echo "Node.js: $(node --version)"
    echo "npm: $(npm --version)"
    echo "Java: $JAVA_HOME"
    echo "Android SDK: $ANDROID_HOME"
    echo ""
    echo "Available commands:"
    echo "  setup           - Install dependencies and setup project"
    echo "  create-avd      - Create Android Virtual Device"
    echo "  start-emulator  - Start Android emulator"
    echo "  connect-metro   - Build app and connect Metro (may take 10+ mins first time)"
    echo "  fast-metro      - Connect Metro without building (faster, if app already installed)"
    echo "  manual-build    - Step-by-step manual build process"
    echo "  watch-build     - Monitor build progress in real-time"
    echo "  start-metro     - Start Metro bundler separately"
    echo "  devices         - Show connected devices and emulators"
    echo "  debug-connection- Debug Metro-emulator connection issues"
    echo "  clean           - Clean and reset React Native project"
    echo "  info            - Show React Native environment info"
    echo ""
    echo "React Native commands:"
    echo "  npm start        - Start Metro bundler (alternative to start-metro)"
    echo "  npm run android  - Build and run on Android (alternative to connect-metro)"
    echo "  npm run ios      - Run on iOS (macOS only)"
    echo ""

    # Verify Android SDK setup
    if [ -z "$ANDROID_HOME" ]; then
      echo "⚠️  ANDROID_HOME not set. Android development may not work."
    else
      echo "✅ Android SDK configured"
    fi

    # Check if project dependencies are installed
    if [ ! -d "node_modules" ]; then
      echo "📦 Dependencies not installed. Run 'setup' to install them."
    else
      echo "✅ Dependencies installed"
    fi
    echo ""
  '';
in
{
  # Enable dotenv support and disable hints for cleaner output
  dotenv.disableHint = true;

  # Environment variables
  env = {
    # React Native specific environment variables
    REACT_NATIVE_PACKAGER_HOSTNAME = "localhost";
    FLIPPER_DISABLE_PLUGIN_FOLDER = "1"; # Disable Flipper to avoid issues
  };

  # Install essential packages for React Native development
  packages = with pkgs; [
    git
    nodejs_20 # React Native 0.80+ requires Node 18+
    watchman # Facebook's file watching service (essential for React Native)
    jq # JSON processor for package.json manipulation
    curl # For network requests
    unzip # For extracting archives

    # Java for Android development
    jdk17 # Java 17 required for React Native/Android

    # Development tools
    tree # Directory tree viewer
    gnused # Stream editor
  ];

  # Configure JavaScript/Node.js environment
  languages.javascript = {
    enable = true;
    package = pkgs.nodejs_20;
    npm.enable = true;
    yarn.enable = false; # Using npm as specified in package.json
    corepack.enable = true; # Enable corepack for package manager management
  };

  # Configure minimal Android development environment
  android = {
    enable = true;
    reactNative.enable = true;

    # Minimal Android SDK configuration
    platforms.version = [ "34" ]; # Just one recent API level
    systemImageTypes = [ "google_apis" ]; # Just google_apis, not playstore
    abis = [ "x86_64" ]; # Just x86_64 for emulator

    # Essential build tools only
    buildTools.version = [ "34.0.0" ];
    cmdLineTools.version = "11.0";
    platformTools.version = "34.0.5";

    # Basic emulator
    emulator = {
      enable = true;
      version = "34.1.9";
    };

    # Disable heavy components for now
    ndk.enable = false; # Skip NDK initially
    googleAPIs.enable = false; # Skip extra APIs
    systemImages.enable = true; # Need this for emulator
    sources.enable = false; # Skip sources

    # Minimal licenses
    extraLicenses = [
      "android-sdk-preview-license"
    ];
  };

  # Custom scripts for common React Native tasks
  scripts = {
    # Install React Native dependencies
    setup.exec = ''
      echo "Setting up React Native project..."
      npm install
      echo "✅ React Native project setup complete!"
      echo ""
      echo "Next steps:"
      echo "1. Run 'create-avd' to create an Android emulator"
      echo "2. Run 'start-emulator' to start the emulator"
      echo "3. Run 'connect-metro' to build and connect to emulator"
    '';

    # Create Android Virtual Device
    create-avd.exec = ''
      echo "Creating Android Virtual Device..."
      avdmanager create avd --force --name RNEmulator --package 'system-images;android-34;google_apis;x86_64' --device "pixel_6"
      echo "AVD created successfully! Use 'start-emulator' to launch it."
    '';

    # Start Android emulator
    start-emulator.exec = ''
      echo "Starting Android emulator..."
      emulator -avd RNEmulator -skin 1080x2340 -no-snapshot-save &
      echo "Emulator starting in background..."
      echo "Wait for emulator to fully boot before running 'connect-metro'"
    '';

    # Enhanced Metro connection with progress monitoring
    connect-metro.exec = ''
      echo "🔍 Checking emulator connection..."

      # Wait for emulator with timeout
      timeout=60
      count=0
      while [ $count -lt $timeout ]; do
        if adb devices | grep -q "device$"; then
          echo "✅ Emulator is ready!"
          break
        fi
        echo "Waiting for emulator to be ready..."
        sleep 2
        count=$((count + 2))
      done

      if [ $count -ge $timeout ]; then
        echo "❌ Emulator not ready after $timeout seconds. Please check emulator status."
        exit 1
      fi

      echo "Connected devices:"
      adb devices

      echo ""
      echo "🚀 Starting Metro bundler in background..."
      npx react-native start --reset-cache &
      METRO_PID=$!

      echo "⏳ Waiting for Metro to start (10 seconds)..."
      sleep 10

      echo "🔧 Setting up Metro port forwarding..."
      adb reverse tcp:8081 tcp:8081

      echo ""
      echo "📱 Building and installing React Native app..."
      echo "⚠️  First build may take 5-15 minutes - this is normal!"
      echo "💡 You can monitor progress in another terminal with: 'watch-build'"

      # Run the build with timeout and progress monitoring
      timeout 900 npx react-native run-android --active-arch-only || {
        echo ""
        echo "❌ Build timed out or failed. Try these alternatives:"
        echo "1. Run 'fast-metro' for Metro-only connection"
        echo "2. Run 'manual-build' for step-by-step build"
        echo "3. Check 'debug-connection' for troubleshooting"
        kill $METRO_PID 2>/dev/null
        exit 1
      }

      echo ""
      echo "🎉 App should now be running on emulator!"
      echo "Metro bundler is running in background (PID: $METRO_PID)"
      echo "Use 'Ctrl+C' to stop, or 'pkill -f metro' to kill Metro later"
    '';

    # Fast Metro connection (skips build, assumes app is already installed)
    fast-metro.exec = ''
      echo "🚀 Fast Metro connection (no build)..."

      # Check if emulator is ready
      if ! adb devices | grep -q "device$"; then
        echo "❌ No emulator detected. Run 'start-emulator' first."
        exit 1
      fi

      echo "🔧 Setting up port forwarding..."
      adb reverse tcp:8081 tcp:8081

      echo "📡 Starting Metro bundler..."
      npx react-native start --reset-cache
    '';

    # Manual step-by-step build process
    manual-build.exec = ''
      echo "🔧 Manual build process - step by step..."

      echo ""
      echo "Step 1: Clean previous builds..."
      cd android && ./gradlew clean && cd ..

      echo ""
      echo "Step 2: Check emulator connection..."
      adb devices

      echo ""
      echo "Step 3: Set up port forwarding..."
      adb reverse tcp:8081 tcp:8081

      echo ""
      echo "Step 4: Start Metro (in new terminal, run: npm start)"
      echo "Press Enter when Metro is running..."
      read

      echo ""
      echo "Step 5: Build and install app..."
      npx react-native run-android --active-arch-only
    '';

    # Watch build progress in real-time
    watch-build.exec = ''
      echo "📊 Monitoring Android build progress..."
      echo "💡 Run this in a separate terminal while connect-metro is running"
      echo ""

      # Watch Gradle build output
      if [ -f android/build.gradle ]; then
        cd android
        ./gradlew --console=plain build --info --no-daemon 2>&1 | grep -E "(task|BUILD|SUCCESSFUL|FAILED|:app:|Download)"
      else
        echo "❌ No Android project found. Make sure you're in the React Native project root."
      fi
    '';

    # Advanced debugging
    debug-connection.exec = ''
      echo "🔧 Debugging Metro-Emulator connection..."
      echo ""
      echo "1. Checking adb devices:"
      adb devices
      echo ""
      echo "2. Checking emulator list:"
      emulator -list-avds
      echo ""
      echo "3. Checking Metro port:"
      netstat -tlnp | grep :8081 || echo "Metro not running on port 8081"
      echo ""
      echo "4. Testing adb reverse:"
      adb reverse tcp:8081 tcp:8081 && echo "✅ Port forwarding set up" || echo "❌ Port forwarding failed"
      echo ""
      echo "5. React Native info:"
      npx react-native info
    '';

    # Show device status
    devices.exec = ''
      echo "Connected Android devices:"
      adb devices
      echo ""
      echo "Available emulators:"
      emulator -list-avds
      echo ""
      echo "Metro port status:"
      netstat -tlnp | grep :8081 || echo "Metro not running"
    '';

    # Start Metro bundler separately
    start-metro.exec = ''
      echo "Starting Metro bundler..."
      echo "This will start Metro in the foreground."
      echo "Use Ctrl+C to stop, or run in separate terminal."
      npx react-native start
    '';

    # Clean React Native project
    clean.exec = ''
      echo "Cleaning React Native project..."
      rm -rf node_modules
      npm install
      npx react-native start --reset-cache
    '';

    # Show React Native info
    info.exec = ''
      echo "React Native Environment Info:"
      echo "Node.js: $(node --version)"
      echo "npm: $(npm --version)"
      echo "Java: $JAVA_HOME"
      echo "Android SDK: $ANDROID_HOME"
      echo ""
      npx react-native info || echo "Run 'npm install' first"
    '';

    # Show help
    help.exec = ''
      ${helpMsg}
    '';
  };

  # Shell initialization
  enterShell = ''
    ${helpMsg}
  '';

  # Tests configuration
  enterTest = ''
    echo "Running React Native project tests..."
    npm test
  '';
}
