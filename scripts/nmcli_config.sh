#!/bin/bash
# *Español*
# scripts/nmcli_config.sh: Script para configurar conexiones de red usando nmcli
# Uso:
#   ./scripts/nmcli_config.sh 
# Preguntará al usuario por los parámetros necesarios para crear o modificar una conexión de red uno a uno.
# Requiere: nmcli (NetworkManager)
# Autor: Ignacio Sánchez

# *English*
# scripts/nmcli_config.sh: Script to configure network connections using nmcli
# Usage:
#   ./scripts/nmcli_config.sh
# It will ask the user for the necessary parameters to create or modify a network connection one by
# one.
# Requires: nmcli (NetworkManager)
# Author: Ignacio Sánchez
set -euo pipefail

usage() { echo "Use: $0"; exit 2; }
# Check if nmcli is installed
if ! command -v nmcli &>/dev/null; then
    echo "Error: nmcli is not installed. Please install NetworkManager."
    exit 1
fi

echo "Welcome to the nmcli network configuration script."
echo "This script will help you create or modify a network connection using nmcli."

nmcli device

read -p "Enter the connection name (last column): " conn_name

read -p "Enter the ipv4 method (auto/manual): " ipv4_method
if [[ "$ipv4_method" == "manual" ]]; then
    read -p "Enter the IPv4 address (e.g., 192.168.1.100/24): " ipv4_address
    read -p "Enter the IPv4 gateway (e.g., 192.168.1.1, leave empty for none): " ipv4_gateway
    read -p "Enter the IPv4 DNS servers (comma-separated, e.g., 8.8.8.8,8.8.4.4, leave empty for none): " ipv4_dns
fi

if nmcli connection show "$conn_name" &>/dev/null; then
    echo "Modifying existing connection: $conn_name"
    if [[ "$ipv4_method" == "manual" ]]; then
        # Build modify arguments for manual mode
        MODIFY_ARGS=(ipv4.method manual ipv4.addresses "$ipv4_address")
        if [[ -n "${ipv4_gateway:-}" ]]; then
            MODIFY_ARGS+=(ipv4.gateway "$ipv4_gateway")
        else
            # Explicitly clear gateway if empty
            MODIFY_ARGS+=(ipv4.gateway "")
        fi
        if [[ -n "${ipv4_dns:-}" ]]; then
            MODIFY_ARGS+=(ipv4.dns "$ipv4_dns")
        else
            # Explicitly clear DNS if empty
            MODIFY_ARGS+=(ipv4.dns "")
        fi
        nmcli connection modify "$conn_name" "${MODIFY_ARGS[@]}"
    else
        nmcli connection modify "$conn_name" ipv4.method auto
    fi
else
    echo "Creating new connection: $conn_name"
    if [[ "$ipv4_method" == "manual" ]]; then
        # Build add arguments for manual mode; omit gateway/dns if empty
        ADD_ARGS=(type ethernet con-name "$conn_name" ifname "*" ipv4.method manual ipv4.addresses "$ipv4_address")
        if [[ -n "${ipv4_gateway:-}" ]]; then
            ADD_ARGS+=(ipv4.gateway "$ipv4_gateway")
        fi
        if [[ -n "${ipv4_dns:-}" ]]; then
            ADD_ARGS+=(ipv4.dns "$ipv4_dns")
        fi
        nmcli connection add "${ADD_ARGS[@]}"
    else
        nmcli connection add type ethernet con-name "$conn_name" ifname "*" ipv4.method auto
    fi
fi

echo "Bringing up the connection: $conn_name"
nmcli connection up "$conn_name"