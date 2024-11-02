
# Openlib Project Setup Guide

Welcome to the **Openlib Project**! This guide will walk you through setting up the project on your local machine, specifically focusing on **Android Studio**. 

### Prerequisites
Before you begin, make sure you have the following installed and configured on your system:

- **Flutter**: Follow [Flutter installation instructions](https://docs.flutter.dev/get-started/install).
  - To verify Flutter installation, run:
    ```bash
    flutter doctor
    ```
- **Git**: Required to clone the repository.
- **Android Studio** (recommended): With Flutter plugin support.

---

## Steps to Set Up Locally

### 1. Create a Project Directory
First, decide where you want the project folder to be created. You can do this from the terminal as follows:
```bash
mkdir OpenlibProject
cd OpenlibProject
```

### 2. Clone the Repository
Use Git to clone the project into your newly created directory:
```bash
git clone https://github.com/dstark5/Openlib.git
```

### 3. Navigate to the Project Folder
After cloning, move into the **Openlib** folder:
```bash
cd Openlib
```

### 4. Open the Project in Android Studio or VS Code
To open the project:
- **For VS Code**: Use:
  ```bash
  code .
  ```
- **For Android Studio**: Open Android Studio, and then use **File > Open** to navigate to the Openlib folder.

### 5. local.properties changes
To ensure compatibility with your target Android devices, update the minimum SDK version:
1. Open **local.properties** (located in `android/`).
2. Add the below properties:
   ```gradle
    flutter.buildMode=release
    flutter.minSdkVersion=21
    flutter.targetSdkVersion=34
    flutter.compileSdkVersion=34
   ```
   Here, `"21"` represents the minimum SDK version supported.

### 6. Enable Flutter Support in Android Studio
To access the emulator options and additional Flutter-specific features:
- Go to **File > Settings > Plugins** in Android Studio.
- Ensure **Flutter** support is enabled.
- This will provide access to the emulator tab, where you can choose the device for testing.

### 7. Run the Application
To run the app:
1. Open **main.dart** (usually found under `lib/`).
2. Use the **Run** button in Android Studio to launch the app on your selected emulator or connected device.

---

## Additional Resources and Troubleshooting
If you encounter any issues, refer to the official [Flutter documentation](https://docs.flutter.dev/) for comprehensive troubleshooting and setup tips.

---

Feel free to reach out or create an issue if you have any questions or need further assistance.
