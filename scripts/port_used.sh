#!/bin/bash
# *Español*
# scripts/port_used.sh: Dado un puerto numérico, devuelve el PID del proceso
# que lo está usando (o nada si está libre).
# Uso:
#   ./scripts/port_used.sh <puerto-numérico>
# Salidas:
#   - Si el puerto está en uso, imprime el PID del proceso que lo usa.
#   - Si el puerto está libre, imprime un mensaje y sale con código 1.
#   - Si hay un error (argumentos inválidos, no se puede extraer PID), sale con código 2 o 3.
# Requiere: ss (iproute2)
# Autor: Ignacio Sánchez 

# *English*
# scripts/port_used.sh: Given a numeric port, returns the PID of the process
# using it (or nothing if free).
# Usage:
#   ./scripts/port_used.sh <numeric-port>
# Outputs:
#   - If the port is in use, prints the PID of the process using it.
#   - If the port is free, prints a message and exits with code 1.
#   - If there's an error (invalid arguments, can't extract PID), exits with code 2 or 3.
# Requires: ss (iproute2)
# Author: Ignacio Sánchez 
set -euo pipefail

usage() { echo "Use: $0 <port>"; exit 2; }

# 1) Argument validation
if [[ $# -ne 1 ]]; then
  echo "Error: must provide exactly one argument (port number)."
  usage
fi

port="$1"
if ! [[ "$port" =~ ^[0-9]{1,5}$ ]] || (( port < 0 || port > 65535 )); then
  echo "Error: port must be a number between 0 and 65535."
  exit 2
fi

# 2) Take only the FIRST occurrence and extract the PID
# Note: -H removes the header. The filter '( sport = :PORT )' limits to the local port.
line=$(ss -H -tunlp "( sport = :$port )" 2>/dev/null | head -n1 || true)

if [[ -z "$line" ]]; then
  echo "Port $port is free (no sockets in LISTEN/USO local)."
  exit 1
fi

pid=$(grep -oP '(?<=pid=)[0-9]+' <<<"$line" | head -n1 || true)

if [[ -n "$pid" ]]; then
  echo "Port $port is in use by process: $pid"
  
  # Ask the user if they want to kill the process
  read -p "Do you want to kill process $pid ($info)? (y/n): " response
  if [[ "$response" == "y" || "$response" == "Y" || "$response" == "yes" || "$response" == "YES" ]]; then
    kill "$pid" && echo "Process $pid terminated." || echo "Could not terminate process $pid (try with sudo)."
  fi
else
  echo "Could not extract PID (try with sudo if permission is denied):"
  echo "  sudo ss -H -tunlp '( sport = :$port )'"
  exit 3
fi
