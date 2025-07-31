#!/bin/bash
set -euo pipefail

# Configuration
ODOO_VERSION="latest"
POSTGRES_USER="odoo"
POSTGRES_PASSWORD="odoo"
POSTGRES_DB="postgres"
ODOO_PORT="8069"
ADMIN_PASS="admin123"

# Check for bash
if [ -z "${BASH_VERSION:-}" ]; then
  echo "Please run this script with bash."
  exit 1
fi

echo "Installing Odoo with Docker..."

# Install Docker if not available
if ! command -v docker &>/dev/null; then
  echo "Docker is not installed. Installing Docker..."
  sudo apt update -y
  sudo apt install -y ca-certificates curl gnupg lsb-release
  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt update -y
  sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
else
  echo "Docker is already installed."
fi

# Install Docker Compose plugin if needed
if ! docker compose version &>/dev/null; then
  sudo apt install -y docker-compose-plugin
fi

# Add user to docker group if needed
if ! groups "$USER" | grep -q '\bdocker\b'; then
  echo "Adding current user to docker group..."
  sudo usermod -aG docker "$USER"
  echo "Please log out and log back in to apply group change."
fi

# Create necessary directories
mkdir -p config addons

# Create odoo.conf
cat > config/odoo.conf <<EOF
[options]
admin_passwd = ${ADMIN_PASS}
db_host = db
db_port = 5432
db_user = ${POSTGRES_USER}
db_password = ${POSTGRES_PASSWORD}
addons_path = /mnt/extra-addons
logfile = /var/log/odoo/odoo.log
proxy_mode = False
EOF

# Create docker-compose.yml
cat > docker-compose.yml <<EOF
version: "3.8"
services:
  db:
    image: postgres:13
    environment:
      POSTGRES_DB: ${POSTGRES_DB}
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    ports:
      - "5432:5432"
    volumes:
      - odoo-db-data:/var/lib/postgresql/data
    restart: always

  odoo:
    image: odoo:${ODOO_VERSION}
    depends_on:
      - db
    ports:
      - "${ODOO_PORT}:8069"
    volumes:
      - ./config/odoo.conf:/etc/odoo/odoo.conf
      - ./addons:/mnt/extra-addons
      - odoo-web-data:/var/lib/odoo
    environment:
      HOST: db
      USER: ${POSTGRES_USER}
      PASSWORD: ${POSTGRES_PASSWORD}
    restart: always

volumes:
  odoo-db-data:
  odoo-web-data:
EOF

# Get IPv4 of VPS
IPV4=$(ip -4 addr show scope global | grep inet | awk '{print $2}' | cut -d/ -f1 | head -n 1)
IPV4=${IPV4:-localhost}

# Open firewall if ufw exists
if command -v ufw &>/dev/null; then
  sudo ufw allow ${ODOO_PORT}/tcp || true
  sudo ufw allow 5432/tcp || true
fi

# Start containers
docker compose up --pull always -d

# Display info
echo
echo "Odoo is up and running!"
echo
echo "Master Password:"
echo "  ${ADMIN_PASS}"
echo
echo "Access Odoo:"
echo "  http://${IPV4}:${ODOO_PORT}"
echo
echo "PostgreSQL connection info:"
echo "  Host:     ${IPV4}"
echo "  Port:     5432"
echo "  User:     ${POSTGRES_USER}"
echo "  Password: ${POSTGRES_PASSWORD}"
echo "  Database: ${POSTGRES_DB}"
echo
echo "PostgreSQL URI:"
echo "  postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${IPV4}:5432/${POSTGRES_DB}"
