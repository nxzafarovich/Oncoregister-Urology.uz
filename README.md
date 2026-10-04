# Onco Register — native macOS project

This is the native SwiftUI version of Onco Register.

## Important architecture
Place the final **Onco Register.app** directly inside the shared network folder used by all doctors.

Example:

Shared Oncology/
├── Onco Register.app
├── Onco Register Data/
│   └── onco_register.sqlite
├── Onco Register Exports/
└── Onco Register Backups/

The three folders are created automatically next to the app.

All doctors must launch the app from the SAME shared network folder.
That makes them read/write the same database.

## Build on your Mac
Requirements: macOS 13+ and Xcode.

1. Unzip this project.
2. Double-click `OncoRegister.xcodeproj`.
3. Select target **Onco Register**.
4. Press Run to test.

Or double-click:

`Build_Unsigned_App.command`

It runs xcodebuild and produces:

`build/Onco Register.app`

## Why this must be built on a Mac
A real macOS executable is produced by Apple's macOS SDK/Xcode.
This project was prepared ready for Xcode, but the final binary must be compiled on a Mac.

## Apple signing
For use only on your internal Macs you can build unsigned and use:
System Settings → Privacy & Security → Open Anyway
if macOS blocks the first launch.

For normal distribution without warnings:
1. Add an Apple Developer account in Xcode.
2. Target → Signing & Capabilities.
3. Select your Team.
4. Build/archive.
5. Developer ID + Apple notarization is required for external distribution.

## Database and network safety
The app uses SQLite in rollback-journal mode (`journal_mode=DELETE`), NOT WAL.
WAL is intentionally not used because SQLite WAL shared-memory behavior is not suitable
for a database file located on a network share.

Writes also use an additional short-lived `.onco_write_lock` directory next to the DB
before `BEGIN IMMEDIATE`, reducing the chance of two workstations writing simultaneously.

The network share must support normal file locking (typical modern SMB shares do).
Keep automatic backups.

## Included
- RU / UZ / EN
- Center logo
- Click logo/header to return Home
- Search by PINFL / full name
- New patient form
- Shared patient database
- Duplicate PINFL protection
- Monthly patient list
- Monthly Excel-compatible `.xls` export
- One-page A4 print card
- Backup button
- Doctor dropdown list
- Center-specific treatment:
  - surgery
  - intravesical instillations
  - hormonal therapy
- Auto-filled editable operation descriptions
- Creator:
  - RU: Нуриддинов Хусниддин Зафариддин угли
  - UZ: Nuriddinov Xusniddin Zafariddin o'g'li
  - EN: Nuriddinov Khusniddin Zafariddin ugli
  - E-mail: nxzafarovich@gmail.com
