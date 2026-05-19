# Lock In (Progress Bar)

A lightweight macOS menu bar app that shows a tiny progress bar for how many of today’s tasks you’ve completed.

**Download:** [Latest release (LockIn.dmg)](https://github.com/kevinesmaelliu/lock-in/releases/latest/download/LockIn.dmg)  
**Marketing site:** [lockin.humaneintuition.com](https://lockin.humaneintuition.com)

## Features

- **Menu bar indicator** — a small capsule bar that fills as you complete tasks (hover for `3/5 done (60%)`)
- **Popover panel** — add tasks, check them off, swipe to delete, clear completed
- **Daily reset** — tasks are scoped to the calendar day; a new day starts with a fresh list
- **No Dock icon** — lives only in the menu bar

## Requirements

- macOS 13 (Ventura) or later
- Xcode 15+ (to build and run locally)

## Run locally

1. Open `ProgressBar.xcodeproj` in Xcode.
2. Select the **ProgressBar** scheme and your Mac as the run destination.
3. Press **⌘R** to build and run.
4. Look for the progress bar in the menu bar (top right). Click it to manage tasks.

On first run, Xcode may ask you to set a **Development Team** under Signing & Capabilities for code signing.

## Releasing

Releases are automated when you push a version tag:

```bash
git tag v1.0.0
git push origin v1.0.0
```

GitHub Actions builds the app, packages **`LockIn.dmg`** (containing **Lock In.app**), and publishes a GitHub Release. The landing page should always link to:

```text
https://github.com/kevinesmaelliu/lock-in/releases/latest/download/LockIn.dmg
```

### Build locally (optional)

```bash
brew install create-dmg
VERSION=1.0.0 ./scripts/build-release.sh
# Output: build/dist/LockIn.dmg
```

### Code signing & notarization (recommended)

Without secrets, CI produces an **ad-hoc signed** DMG. Users can open it via **Right-click → Open**. For a smooth install experience, add these [repository secrets](https://github.com/kevinesmaelliu/lock-in/settings/secrets/actions):

| Secret | Description |
|--------|-------------|
| `APPLE_CERTIFICATE_BASE64` | Base64-encoded `.p12` (Developer ID Application) |
| `APPLE_CERTIFICATE_PASSWORD` | Password for the `.p12` |
| `APPLE_SIGNING_IDENTITY` | e.g. `Developer ID Application: Your Name (TEAMID)` |
| `APPLE_TEAM_ID` | 10-character Team ID |
| `APPLE_ID` | Apple ID email (for notarization) |
| `APPLE_APP_SPECIFIC_PASSWORD` | App-specific password |

**Or** use App Store Connect API key instead of Apple ID + app password:

| Secret | Description |
|--------|-------------|
| `APP_STORE_CONNECT_API_KEY_ID` | Key ID |
| `APP_STORE_CONNECT_API_ISSUER_ID` | Issuer ID |
| `APP_STORE_CONNECT_API_KEY` | Base64-encoded `.p8` key contents |

Export the certificate from Keychain Access → export as `.p12`, then:

```bash
base64 -i Certificates.p12 | pbcopy
```

## Project structure

```
ProgressBar/
  ProgressBarApp.swift
  Models/          DailyTask, TaskStore, AppSettings
  Views/           Menu bar UI, settings
scripts/
  build-release.sh # CI + local release packaging
.github/workflows/
  release.yml      # Tag-triggered release
```

Tasks are stored in `UserDefaults` under `com.progressbar.daily.tasks`.
