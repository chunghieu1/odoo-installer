# Auto Odoo Installer

A fully automated script to install Odoo using Docker and Docker Compose. No manual steps, no config files to edit — just run and go.

## Features

- Silent and unattended setup
- Automatically installs Docker & Docker Compose
- Sets up Odoo and PostgreSQL using Docker Compose
- Creates default Odoo config with master password
- Auto-detects VPS public IP and shows access URL
- Opens required firewall ports (if ufw is installed)
- Works out-of-the-box on Ubuntu VPS (18.04+)

## Requirements

- Ubuntu-based server (18.04 or later)
- Root or sudo privileges
- Internet connection

## Usage

### 1. Clone the repository

```bash
git clone https://github.com/chunghieu1/odoo-installer.git
cd odoo-installer
```

### 2. Run the installation script

```bash
chmod +x setup.sh
./setup.sh
```

This script will:
- Install Docker and Docker Compose if missing
- Set up Odoo configuration and Docker Compose file
- Pull the latest Odoo and PostgreSQL images
- Launch containers in the background

### 3. Run directly using curl (optional)

You can skip cloning and run the script directly:

```bash
bash <(curl -sSL https://raw.githubusercontent.com/chunghieu1/odoo-installer/main/setup.sh)
```

### 4. Access Odoo

After installation, open your browser and go to:

```
http://your-server-ip:8069
```

Replace `your-server-ip` with your VPS public IP address.

You'll see the database setup screen. Use the master password shown in the terminal output.

## Default Credentials

**Master Password:** `admin123` (Shown after install — needed to create the first Odoo database)

**PostgreSQL Connection Info:**
- Host: your VPS IP
- Port: 5432
- User: odoo
- Password: odoo
- Database: postgres

## Notes

- You can edit `config/odoo.conf` to customize Odoo later.
- Make sure to open port 8069 in your VPS firewall/security group.

- For advanced customization, refer to [Odoo Docker Hub](https://hub.docker.com/_/odoo).

---
## License

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
