# Ping Responder

A simple Rust application that starts an HTTP server responding with `200 OK` to any request.

## Features

- **Port Selection:** Specify a custom port using the `--port` or `-p` flag. Defaults to port `5555`.
- **No Output:** The application runs silently unless an error occurs.
- **Cross-Platform:** Supports Linux x64, Linux ARM64, and Windows x64.

## Installation

### Prerequisites

- **Dependencies:** `curl`, `unzip`, `systemctl` (for Linux systems).
- **GitHub Account:** Replace `yourusername` and `ping_server` in scripts with your GitHub username and repository name.

### Steps

1. **Download the Installation Script:**

   ```bash
   wget https://raw.githubusercontent.com/ATCUSA/pingResponder/master/install.sh
