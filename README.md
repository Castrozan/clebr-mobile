# Clebr Mobile

A React Native application with a fully configured development environment using devenv.

## Development Environment Setup with devenv

This project uses [devenv](https://devenv.sh/) to provide a consistent, reproducible development environment with all necessary tools for React Native development.

### Prerequisites

1. **Install Nix** (required for devenv):
   - **Linux**: `curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install`
   - **macOS**: `curl -L https://raw.githubusercontent.com/NixOS/experimental-nix-installer/main/nix-installer.sh | sh -s install`
   - **Windows (WSL2)**: `sh <(curl -L https://nixos.org/nix/install) --no-daemon`

2. **Install Cachix** (optional but recommended for faster builds):
   ```bash
   nix-env -iA cachix -f https://cachix.org/api/v1/install
   echo "trusted-users = root ${USER}" | sudo tee -a /etc/nix/nix.conf && sudo pkill nix-daemon
   cachix use devenv
   ```

3. **Install devenv**:
   ```bash
   nix-env -iA devenv -f https://github.com/NixOS/nixpkgs/tarball/nixpkgs-unstable
   ```

4. **Install direnv** (optional but recommended for automatic environment activation):
   - **Linux (Ubuntu/Debian)**: `apt install direnv`
   - **macOS**: `brew install direnv`
   
   Then add to your shell profile (`.bashrc`, `.zshrc`, etc.):
   ```bash
   eval "$(direnv hook bash)"  # for bash
   eval "$(direnv hook zsh)"   # for zsh
   ```

### Getting Started

1. **Clone and enter the project**:
   ```bash
   cd /path/to/clebr-mobile
   ```

2. **Activate the development environment**:
   
   **Option A: With direnv (automatic)**:
   ```bash
   direnv allow
   # Environment will activate automatically when you cd into the directory
   ```
   
   **Option B: Manual activation**:
   ```bash
   devenv shell
   ```

3. **Setup the project**:
   ```bash
   setup  # This installs npm dependencies and shows next steps
   ```

### Available Commands

Once in the devenv environment, you have access to these custom commands:

- **`setup`** - Install React Native dependencies and show setup instructions
- **`create-avd`** - Create an Android Virtual Device for testing
- **`start-emulator`** - Start the Android emulator
- **`devices`** - Show connected Android devices and available emulators
- **`clean`** - Clean and reset the React Native project

### Standard React Native Commands

- **`npm start`** - Start the Metro bundler
- **`npm run android`** - Build and run the app on Android
- **`npm run ios`** - Build and run the app on iOS (macOS only)
- **`npm test`** - Run the test suite
- **`npm run lint`** - Run ESLint

### What's Included

The devenv configuration automatically provides:

- **Node.js 20** - Latest LTS version optimized for React Native
- **Java 17** - Required for Android development
- **Android SDK** - Complete Android development toolkit
- **Android Emulator** - For testing on virtual devices
- **Watchman** - Facebook's file watching service
- **Development Tools** - git, curl, jq, and other utilities

### Typical Workflow

1. **First-time setup**:
   ```bash
   cd clebr-mobile
   direnv allow          # If using direnv
   setup                 # Install dependencies
   create-avd           # Create Android emulator
   ```

2. **Daily development**:
   ```bash
   cd clebr-mobile       # Environment activates automatically with direnv
   start-emulator       # Start Android emulator (in background)
   npm start            # Start Metro bundler
   npm run android      # Build and run app (in another terminal)
   ```

3. **Check status**:
   ```bash
   devices              # See connected devices and emulators
   ```

### Troubleshooting

**Environment not loading?**
- Make sure you're in the project directory
- If using direnv, run `direnv allow`
- If not using direnv, run `devenv shell`

**Android emulator issues?**
- Ensure ANDROID_HOME is set (should be automatic in devenv)
- Check available emulators with `devices`
- Create a new emulator with `create-avd`

**Build failures?**
- Clean the project with `clean`
- Restart Metro bundler: `npm start -- --reset-cache`

**Dependencies out of sync?**
- Run `setup` to reinstall dependencies
- For major issues, try `clean`

### iOS Development (macOS only)

For iOS development, you'll also need:
- Xcode (install from Mac App Store)
- Xcode Command Line Tools
- CocoaPods dependencies: `cd ios && pod install`

### Environment Maintenance

- **Update packages**: The environment uses rolling nixpkgs, so restart your shell to get updates
- **Clean old builds**: Run `devenv gc` periodically to clean up unused packages
- **Reset environment**: Delete `.devenv` folder and re-enter the environment

### Learn More

- [React Native Documentation](https://reactnative.dev/)
- [devenv Documentation](https://devenv.sh/)
- [Nix Package Manager](https://nixos.org/manual/nix/stable/)

### Contributing

When contributing to this project, the devenv configuration ensures all developers have an identical development environment, reducing "works on my machine" issues.

Make sure to:
1. Use the provided devenv environment
2. Run `npm run lint` before committing
3. Test on both Android emulator and physical device when possible
