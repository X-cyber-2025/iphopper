#!/bin/bash
# ----------------------------------
# 🔁 IPHopper - IP Changing Tool
# Fixed & Optimized by Ar-Raiyan
# Tor + Privoxy (DNS Safe)
# ----------------------------------

clear

# ===== Banner =====
echo -e "\e[1;36m"
echo "██╗  ██╗      ██████╗██╗   ██╗██████╗ ███████╗██████╗ "
echo "╚██╗██╔╝     ██╔════╝╚██╗ ██╔╝██╔══██╗██╔════╝██╔══██╗"
echo " ╚███╔╝█████╗██║      ╚████╔╝ ██████╔╝█████╗  ██████╔╝"
echo " ██╔██╗╚════╝██║       ╚██╔╝  ██╔══██╗██╔══╝  ██╔══██╗"
echo "██╔╝ ██╗     ╚██████╗   ██║   ██████╔╝███████╗██║  ██║"
echo "╚═╝  ╚═╝      ╚═════╝   ╚═╝   ╚═════╝ ╚══════╝╚═╝  ╚═╝"
echo -e "\e[0m"
echo -e "\e[1;33m          X-CYBER - IP CHANGING TOOL\e[0m"
echo ""

# ===== Clean old services =====
pkill tor 2>/dev/null
pkill privoxy 2>/dev/null
rm -rf ~/.tor_multi ~/.privoxy
mkdir -p ~/.tor_multi ~/.privoxy

echo -e "\e[1;32m[+] Launching Tor Node & Privoxy...\e[0m"

# ===== Ports =====
SOCKS_PORT=9050
CONTROL_PORT=9051

# ===== Tor config =====
TOR_DIR="$HOME/.tor_multi/tor0"
mkdir -p "$TOR_DIR"

cat <<EOF > "$TOR_DIR/torrc"
SocksPort $SOCKS_PORT
ControlPort $CONTROL_PORT
DataDirectory $TOR_DIR
CookieAuthentication 0
ExitNodes {us}
StrictNodes 1
EOF

tor -f "$TOR_DIR/torrc" > /dev/null 2>&1 &

# ===== Wait for Tor =====
echo -e "\e[1;34m[*] Waiting for Tor to bootstrap...\e[0m"
sleep 15

# ===== Privoxy config (DNS SAFE) =====
cat <<EOF > "$HOME/.privoxy/config"
listen-address 127.0.0.1:8118
forward-socks5t / 127.0.0.1:$SOCKS_PORT .
EOF

privoxy "$HOME/.privoxy/config" > /dev/null 2>&1 &

sleep 3

# ===== Rotation Time =====
echo -ne "\e[1;36mEnter IP change interval (seconds, min 10): \e[0m"
read -r ROTATION_TIME

if [[ ! "$ROTATION_TIME" =~ ^[0-9]+$ ]] || [[ "$ROTATION_TIME" -lt 10 ]]; then
    ROTATION_TIME=10
fi

echo -e "\e[1;32m[✓] IP rotation every $ROTATION_TIME seconds\e[0m"
echo ""

# ===== Rotation Loop =====
while true; do
    echo -e "AUTHENTICATE \"\"\nSIGNAL NEWNYM\nQUIT" | nc 127.0.0.1 $CONTROL_PORT > /dev/null 2>&1

    NEW_IP=$(curl -s --proxy http://127.0.0.1:8118 https://check.torproject.org/api/ip \
        | grep -oE '"IP":"[^"]+' | cut -d'"' -f4)

    echo -e "\e[1;32m🌐 New IP: $NEW_IP\e[0m"
    echo -e "\e[1;34m[Proxy]: 127.0.0.1:8118\e[0m"
    echo "------------------------------------"

    sleep "$ROTATION_TIME"
done