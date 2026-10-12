<div align="center">

<img src="CloudflareTunnelManager/Resources/icon.png" alt="Cloudflare Tunnel Manager Icon" width="128" height="128" />

# Cloudflare Tunnel Manager

A native macOS GUI client to manage and run `cloudflared access` tunnels (SSH, RDP, TCP, SMB).

[![Platform](https://img.shields.io/badge/platform-macOS%2014.6%2B-blue.svg)]()
[![Swift](https://img.shields.io/badge/Swift-5.0%20%7C%206.0-orange.svg)]()
[![SwiftUI](https://img.shields.io/badge/UI-SwiftUI-purple.svg)]()
[![SwiftData](https://img.shields.io/badge/Persistence-SwiftData-green.svg)]()
[![License](https://img.shields.io/badge/license-GPL--3.0-blue.svg)](LICENSE)

</div>

---

## Overview

**Cloudflare Tunnel Manager (CFT Manager)** is a native macOS application designed to simplify connecting to private services protected behind Cloudflare Zero Trust.

Instead of remembering long terminal commands or keeping messy terminal tabs open, CFT Manager gives you a native, one-click interface to configure, start, monitor, and stop your client access tunnels.

### Key Features

- **One-Click Execution**: Start and stop connections directly from one button.
- **Live Console Streaming**: Real-time terminal output pane monitor tunnel logs and connection attempts.
- **Command Previews & Copy**: Generates the exact `cloudflared access` CLI command for instant copying.
- **State Recovery**: Automatically detects and resets stale "Started" statuses after an unexpected crash or force-quit.
- **Native SwiftData Persistence**: All your configurations are safely stored locally using Apple's modern SwiftData framework.
- **Native macOS Experience**: Split-view navigation (`NavigationSplitView`), keyboard shortcuts, dark console aesthetics, and Liquid Glass App Icon design.

---

## Prerequisites

CFT Manager executes `cloudflared` under the hood. Ensure you have the Cloudflare CLI tool installed on your Mac:

```bash
# Install via Homebrew
brew install cloudflared
```

> **Note:** The app automatically locates `cloudflared` in standard installation paths (`/opt/homebrew/bin/cloudflared`, `/usr/local/bin/cloudflared`, or `/usr/bin/cloudflared`).

---

## Installation

### Method 1: Download `.dmg` (Recommended)

1. Go to the [Releases](https://github.com/tudemaha/cloudflare-tunnel-manager/releases) page.
2. Download the latest `CFT-Manager.dmg`.
3. Open the `.dmg` file and drag **CFT Manager** into your **Applications** folder.
4. Launch **CFT Manager** from Launchpad or Spotlight (`⌘ Space`).

> _If macOS shows a security prompt regarding an unidentified developer, open **System Settings > Privacy & Security** and click **Open Anyway**._

---

### Method 2: Build from Source

If you prefer to compile the application yourself:

1. Clone this repository:
   ```bash
   git clone https://github.com/tudemaha/cloudflare-tunnel-manager.git
   cd cloudflare-tunnel-manager
   ```
2. Open the project in Xcode:
   ```bash
   open CloudflareTunnelManager.xcodeproj
   ```
3. Select the **CloudflareTunnelManager** scheme and run (`⌘R`), or build with the command line:
   ```bash
   xcodebuild -scheme CloudflareTunnelManager -destination 'platform=macOS' -quiet build
   ```

---

## How to Use

### 1. Add a Tunnel

- Click the **`+`** button in the sidebar (or click **Add Connection** from the empty state).
- Configure your tunnel parameters:
  - **Connection Type**: Choose between `SSH`, `RDP`, `TCP`, or `SMB`.
  - **Remote Hostname**: The domain configured in your Cloudflare Zero Trust dashboard (e.g., `ssh.production.example.com`).
  - **Local Hostname**: Usually `localhost` or `127.0.0.1`.
  - **Local Port**: The local listening port (e.g., `2222` for SSH, `3389` for RDP).
- Click **Save**.

### 2. Start the Tunnel

- Select your tunnel in the sidebar list.
- Click the green **Start** button in the top-right toolbar.
- The terminal panel at the bottom will open and stream live output from `cloudflared`.

### 3. Connect via Your Client

Once the tunnel is active, connect your favorite client to your local port:

- **SSH**:
  ```bash
  ssh user@localhost -p 2222
  ```
- **RDP**:
  Open Microsoft Remote Desktop and connect to `localhost:3389`.
- **Database / TCP**:
  Point your database tool (e.g. TablePlus, DBeaver) to `127.0.0.1:5432`.

### 4. Stop the Tunnel

- Click the red **Stop** button in the toolbar to cleanly terminate the subprocess and release the local port.

---

## Architecture & Tech Stack

- **Framework**: SwiftUI (macOS 14.6+)
- **Storage**: SwiftData (`@Model final class Tunnel`)
- **Process Orchestration**: Foundation `Process` and `Pipe` isolated on `@MainActor`
- **Icon Design**: Apple Icon Composer (`.icon`)

For full architecture details, coding guidelines, and developer conventions, please see [AGENTS.md](AGENTS.md).

---

## License

This project is licensed under the [GNU General Public License v3.0 (GPLv3)](LICENSE).
