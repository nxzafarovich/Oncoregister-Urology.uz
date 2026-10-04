# Build Onco Register with Codemagic

This project is configured for Codemagic.

## 1. Upload to GitHub
Create a new GitHub repository and upload the CONTENTS of this folder.

Important: `codemagic.yaml` must be in the repository root.

## 2. Connect GitHub to Codemagic
In Codemagic:
- Add application
- Choose GitHub
- Select your repository
- Choose configuration file: `codemagic.yaml`

## 3. Start build
Run workflow:

`Onco Register macOS`

Codemagic will:
1. Start a macOS machine with Xcode.
2. Build the native SwiftUI project.
3. Create an unsigned `Onco Register.app`.
4. Package it into:

`Onco_Register_macOS.zip`

## 4. Download
After the build finishes:
- Open the build
- Open **Artifacts**
- Download `Onco_Register_macOS.zip`

Unzip it and you will have:

`Onco Register.app`

## 5. Put it in the shared folder
The app must be placed directly in the common network folder used by all doctors.

Example:

Shared Oncology/
├── Onco Register.app
├── Onco Register Data/
│   └── onco_register.sqlite
├── Onco Register Exports/
└── Onco Register Backups/

The app creates the three folders automatically.

## 6. First launch
The Codemagic build in this workflow is intentionally UNSIGNED.

On a Mac, Gatekeeper may block the first launch.
Try:
- Control-click the app
- Open
- Open

If needed:
System Settings → Privacy & Security → Open Anyway

For a normal signed/notarized app without Gatekeeper warnings, Apple Developer ID signing and Apple notarization must be configured separately.


## Fix included
This package defines `SQLITE_TRANSIENT` explicitly for Swift's SQLite3 C API, fixing the Codemagic compile error `cannot find 'SQLITE_TRANSIENT' in scope`.
