#!/bin/bash

# System aktualisieren
sudo yum update -y
sudo yum upgrade -y

# V2Ray-Installationsskripte herunterladen und ausführen
curl -O https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh
curl -O https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-dat-release.sh

chmod +x install-release.sh install-dat-release.sh
sudo ./install-release.sh
sudo ./install-dat-release.sh

# Konfigurationsdatei erstellen
sudo mkdir -p /usr/local/etc/v2ray
sudo tee /usr/local/etc/v2ray/config.json > /dev/null <<EOL
{
  "log": {
    "access": "/var/log/v2ray/access.log",
    "error": "/var/log/v2ray/error.log",
    "loglevel": "debug"
  },
  "inbound": {
    "port": 31462,
    "protocol": "vmess",
    "settings": {
      "clients": [
        {
          "id": "b831381d-6324-4d53-ad4f-8cda48b30811",
          "level": 1,
          "alterId": 0
        }
      ]
    }
  },
  "streamSettings": {
    "network": "kcp"
  },
  "detour": {
    "to": "vmess-detour-522598"
  },
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    }
  ]
}
EOL

# Systemd-Service-Datei für V2Ray erstellen
sudo tee /etc/systemd/system/v2ray.service > /dev/null <<EOL
[Unit]
Description=V2Ray Service
Documentation=https://www.v2fly.org/
After=network.target nss-lookup.target

[Service]
User=nobody
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
Environment="V2RAY_VMESS_AEAD_FORCED=false"
ExecStart=/usr/local/bin/v2ray run -config /usr/local/etc/v2ray/config.json
Restart=on-failure
RestartPreventExitStatus=23

[Install]
WantedBy=multi-user.target
EOL

# Systemd neu laden, V2Ray starten und Status überprüfen
sudo systemctl daemon-reload
sudo systemctl restart v2ray
sudo systemctl status v2ray
