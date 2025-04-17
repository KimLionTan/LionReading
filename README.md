# LionReading - Developer Installation Guide
This is TanJianing's final project.
This software is for personal or educational use only. Commercial use is prohibited.
## 1. Introduction

**LionReading** is an iOS app designed to help readers personalize their reading management and receive relevant book recommendations.  
This is a source code project that needs to run in the Xcode environment.

- **Minimum iOS Version**: iOS 17.4  
- **Programming Language**: Swift 5  
- **Recommended IDE**: Xcode 15 or higher

## 2. System Requirements

- **Operating System**: macOS Sonoma (14.0) or higher  
- **Development Environment**: Xcode 15.2 or higher  
- **Processor**: Apple Silicon (M1/M2/M3) or Intel i5/i7  
- **Test Device**: MacBook Air with M2 chip and 16GB RAM  
- **Simulator Compatibility**: Tested on iPhone 16 Pro simulator, iOS 17.4  
- **Framework Dependencies**:  
  - `EventKit`  
  - `SQLite` (via Swift Package Manager)  
- **Privacy Permissions Required**:  
  - Full calendar access  
  - Camera access *(Note: Cannot be verified in simulator)*

## 3. Installation Preparation

### a. Obtain the Source Code

- From proof document: Download and extract the LionReading compressed package.  
- Or clone from GitHub:  
  [https://github.com/KimLionTan/LionReading](https://github.com/KimLionTan/LionReading)

### b. Installation Tools

- **Xcode 15.2 or later**  
  Download from the [Mac App Store](https://apps.apple.com/us/app/xcode/id497799835).

- **System Framework Configuration**
  1. Open your project settings → **General** → **Frameworks, Libraries, and Embedded Content**  
     Add: `EventKit.framework`
  2. In your `Info.plist` file, add the following privacy keys:
     - `Privacy - Calendars Usage Description`
     - `Privacy - Calendars Full Access Usage Description`
     - `Privacy - Camera Usage Description`

- **SQLite Dependency**
  - The project uses Swift Package Manager (SPM).
  - Dependencies will be auto-downloaded on first open.
  - If not, manually add `sqlite.swift` via **File > Add Packages...**

### c. Developer Account Preparation

1. If you don’t have an Apple ID, register at: [https://appleid.apple.com](https://appleid.apple.com)
2. Open Xcode → `Xcode` > `Settings...` > `Accounts`
3. Click the "+" at bottom-left, select "Apple ID", and log in
4. Xcode will auto-create a free developer account, sufficient for simulator use  
   ⚠️ *No physical device required. Paid membership not needed.*

## 4. Run the Application

1. Double-click `LionReading.xcodeproj` in the decompressed folder  
2. Wait for Xcode to load the project and dependencies (may take several minutes)  
3. In the top device selector, choose **iPhone 16 Pro** or any iOS 17.4-compatible simulator  
4. Click the ▶️ play button (top left) to compile and run  
5. On first launch, the simulator will request **calendar access**. Click **Allow** to ensure full functionality
