# AGENTS.md — Cloudflare Tunnel Manager (CFT Manager)

This document provides a comprehensive guide for AI agents and developers working on the **Cloudflare Tunnel Manager** codebase.

---

## 1. Project Overview

**Cloudflare Tunnel Manager** (`CFT Manager`) is a native macOS application built with SwiftUI and SwiftData. It serves as a graphical management client and background process runner for `cloudflared access` connections (SSH, RDP, TCP, SMB).

### Key Features
- **SwiftData Persistence**: Local storage for tunnel connection configurations (`Tunnel` model).
- **Subprocess Runner**: Executes background child `cloudflared access` commands via Foundation `Process` and `Pipe`.
- **Live Terminal Output**: Real-time console streaming of `cloudflared` stdout/stderr with auto-scrolling.
- **State Recovery**: Automatically resets stale `.started` states to `.stopped` on app launch to gracefully handle crashes or force-quits.
- **Native macOS UI**: Split-view layout (`NavigationSplitView`), sidebar navigation with swipe-to-delete, modal sheets, and empty states.

---

## 2. Directory Structure

```text
CloudflareTunnelManager/
├── CloudflareTunnelManager.xcodeproj/    # Xcode project configuration
│   └── project.pbxproj                  # Target, bundle identifier, & build settings
├── CloudflareTunnelManager/              # Root source directory (Xcode synchronized group)
│   ├── CloudflareTunnelManagerApp.swift  # App entry point; ModelContainer & context initialization
│   ├── Models/
│   │   └── Tunnel.swift                  # SwiftData @Model for tunnel configurations & enums
│   ├── Core/                             # Business logic & singleton services
│   │   ├── TunnelStorageManager.swift    # SwiftData CRUD and database sanitization
│   │   ├── ProcessManager.swift          # Process & Pipe subprocess lifecycle & log streaming
│   │   └── CloudflaredLocator.swift      # Binary path resolution (/opt/homebrew/bin, etc.)
│   ├── Views/
│   │   ├── MainView.swift                # Root NavigationSplitView coordinator
│   │   ├── List/                         # Sidebar list views
│   │   │   ├── ListView.swift            # Sidebar tunnel list with search, +, and empty state
│   │   │   └── Components/
│   │   │       └── Item.swift            # Single tunnel sidebar row item
│   │   ├── Detail/                       # Right detail pane views
│   │   │   ├── DetailView.swift          # Detail pane coordinator with empty state
│   │   │   └── Components/
│   │   │       ├── DetailForm.swift      # Main detail orchestrator, toolbar, & Start/Stop toggle
│   │   │       ├── DetailHeader.swift    # Status icon, hostname, Edit, and Delete actions
│   │   │       ├── DetailInfoForm.swift  # Grouped form fields & copyable CLI command preview
│   │   │       └── TerminalView.swift    # Monospaced dark console with auto-scrolling
│   │   └── Form/                         # Create / Edit modals
│   │       └── TunnelFormView.swift      # Sheet for creating or updating a Tunnel
│   └── Resources/
│       ├── icon.png                      # App Icon PNG for README / Documentation
│       ├── CFTManager.icon               # Apple Icon Composer document (App Icon)
│       └── Assets.xcassets/              # AccentColor, AppIcon fallback, color sets
├── .gitignore                            # Standard Xcode / macOS git ignore rules
└── AGENTS.md                             # AI Agent guide and project conventions (this file)
```

---

## 3. Architecture & Design Patterns

### 3.1. Service / Manager Pattern & ViewModel Usage
- **Core Services (`Core/`)**:
  - Global runtime execution, persistent database operations, and background subprocesses belong in `Core/`:
    - **`TunnelStorageManager`**: `@MainActor` singleton managing SwiftData `ModelContext`, database CRUD, and integrity resets.
    - **`ProcessManager`**: `@MainActor @Observable` singleton managing active `Process` and `Pipe` instances, log streaming dictionaries (`logs: [String: [String]]`), and lifecycle termination.
  - **Why**: Subprocess execution and global storage must survive view destruction, sidebar navigation, and window resizing without being killed by view lifecycles.
- **ViewModels (`ViewModels/`)**:
  - ViewModels (`@Observable`) are **welcome and encouraged** as the app scales to manage complex screen states, multi-step forms, or elaborate presentation logic.
  - When introducing ViewModels, ensure they focus on UI and view state, while delegating background process control and data persistence directly to the `Core/` services (`ProcessManager` and `TunnelStorageManager`).

### 3.2. Concurrency & Swift 6 Compatibility
- UI and data access must remain on `@MainActor`.
- Background subprocess output reading is performed asynchronously via `FileHandle.readabilityHandler` and dispatched back to `@MainActor` / `DispatchQueue.main.async` for log appending and state updates.
- App termination cleanup registers `NSApplication.willTerminateNotification` and executes via `MainActor.assumeIsolated`.

### 3.3. State Synchronization & Crash Recovery
- **Single Source of Truth**:
  - `ProcessManager.shared.isRunning(for: host)` determines whether a process is actively alive in the current OS session.
  - `tunnel.state` stores persistent status (`Started`, `Stopped`, `Failed`) in SwiftData.
- **Force-Quit / Crash Sanitization**:
  - A force-quit (`SIGKILL`) prevents exit hooks from running, leaving database records frozen as `.started`.
  - On every app launch in `CloudflareTunnelManagerApp.init()`, `TunnelStorageManager.shared.resetAllStatesToStopped()` runs immediately to reconcile the database.
  - Normal app quits trigger `ProcessManager.shared.stopAll()`, which terminates all child processes and calls `resetAllStatesToStopped()`.

---

## 4. Coding Conventions & Rules

1. **Hostname Sanitization**:
   - `cloudflared access` expects pure hostnames without protocol schemes (e.g. `ssh.example.com` instead of `https://ssh.example.com`).
   - `TunnelFormView` must always strip schemes (`://`) and trailing slashes before saving to `tunnel.remoteHostname`.
2. **Subprocess Execution**:
   - `Process.executableURL` is dynamically resolved by `CloudflaredLocator.findBinary()`.
   - Never hardcode `/opt/homebrew/bin/cloudflared` without checking `/usr/local/bin/cloudflared` and fallback paths.
   - Arguments must follow:
     ```swift
     ["access", tunnel.connectionType.rawValue, "--hostname", host, "--url", "\(tunnel.localHostname):\(tunnel.localPort)"]
     ```
3. **App Sandbox**:
   - **App Sandbox must remain DISABLED** (`ENABLE_APP_SANDBOX = NO` in `project.pbxproj`) so Foundation `Process` can execute external system binaries (`cloudflared`).
4. **App Icon & Asset Catalogs**:
   - The primary app icon is **`CFTManager`** (configured via `ASSETCATALOG_COMPILER_APPICON_NAME = CFTManager`).
   - The Icon Composer package resides at `CloudflareTunnelManager/Resources/CFTManager.icon`.
   - Do **not** drag `.icon` packages into `Assets.xcassets`, as Xcode's asset compiler will misinterpret internal layers.
5. **Xcode 16 PBXFileSystemSynchronizedRootGroup**:
   - The project uses Xcode's synchronized root groups (`CloudflareTunnelManager`).
   - Files added or removed directly on the filesystem are automatically picked up by Xcode without needing manual references in `project.pbxproj`.
6. **Git Cleanliness**:
   - Never commit `*.xcuserdatad`, `xcuserdata/`, or `DerivedData/`.
   - All commits must follow Conventional Commits (`feat:`, `fix:`, `refactor:`, `build:`, `docs:`).

---

## 5. Build & Verification Commands

To verify changes from the command line:

```bash
# Build macOS target using the CloudflareTunnelManager scheme
xcodebuild -scheme CloudflareTunnelManager -destination 'platform=macOS' -quiet build

# Check git status for uncommitted or untracked changes
git status
```
