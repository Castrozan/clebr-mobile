# clebr-mobile

This is a React Native project for the Clebr mobile application.

## Development Environment Setup (NixOS)

This project uses [Nix](https://nixos.org/) with [devenv](https://devenv.sh/) and [direnv](https://direnv.net/) to provide a reproducible development environment.

### Prerequisites

1.  **NixOS**: You must be running NixOS.
2.  **Direnv**: Make sure `direnv` is installed and hooked into your shell.
3.  **Devenv**: Make sure you have `devenv` installed.

### Getting Started

1.  **Clone the repository:**
    ```sh
    git clone <repository-url>
    cd clebr-mobile
    ```

2.  **Allow direnv:**
    When you first `cd` into the directory, `direnv` will prompt you for permission. Allow it to load the environment.
    ```sh
    direnv allow
    ```
    This will install all the necessary dependencies, including the correct versions of Node.js, Java, and the Android SDK.

3.  **Create the Android Emulator:**
    The first time you set up the project, you'll need to create an Android Virtual Device (AVD).
    ```sh
    devenv script create-avd
    ```

4.  **Run the development servers:**
    To start the Metro bundler and the Android emulator, run:
    ```sh
    devenv up
    ```
    This will start both processes in the foreground.

5.  **Run the app on Android:**
    With the emulator running and Metro started, open a new terminal in the same directory (the `devenv` environment will load automatically) and run:
    ```sh
    npm run android
    ```

The app should now be running in your Android emulator.

### Development tasks

-   **Start all processes**: `devenv up`
-   **Run Metro bundler**: `npm start`
-   **Run on Android**: `npm run android` (requires emulator to be running)
-   **Start emulator**: `emulator -avd clebr-emulator`
-   **Access the dev shell**: `devenv shell`

---

This project was bootstrapped with [React Native](https://reactnative.dev).
