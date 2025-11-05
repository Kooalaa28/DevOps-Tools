#!/bin/bash
# scripts/port_used.sh: Dado un puerto numérico, devuelve el PID del proceso
# que lo está usando (o nada si está libre).
# Uso:
#   ./scripts/port_used.sh <puerto-numérico>
# Salidas:
#   - Si el puerto está en uso, imprime el PID del proceso que lo usa.
#   - Si el puerto está libre, imprime un mensaje y sale con código 1.
#   - Si hay un error (argumentos inválidos, no se puede extraer PID), sale con código 2 o 3.
# Requiere: ss (iproute2)
# Autor: Ignacio Sánchez Andreu
set -euo pipefail

usage() { echo "Uso: $0 <puerto-numérico>"; exit 2; }

# 1) Validación de argumentos
if [[ $# -ne 1 ]]; then
  echo "Error: debes pasar exactamente 1 argumento."
  usage
fi

port="$1"
if ! [[ "$port" =~ ^[0-9]{1,5}$ ]] || (( port < 0 || port > 65535 )); then
  echo "Error: el puerto debe ser un número entre 0 y 65535."
  exit 2
fi

# 2) Tomar solo la PRIMERA ocurrencia y extraer el PID
# Nota: -H quita la cabecera. El filtro '( sport = :PORT )' limita al puerto local.
line=$(ss -H -tunlp "( sport = :$port )" 2>/dev/null | head -n1 || true)

if [[ -z "$line" ]]; then
  echo "Puerto $port libre (no hay sockets en LISTEN/USO local)."
  exit 1
fi

pid=$(grep -oP '(?<=pid=)[0-9]+' <<<"$line" | head -n1 || true)

if [[ -n "$pid" ]]; then
  echo "$pid"
else
  echo "No pude extraer el PID (prueba con sudo si falta permiso):"
  echo "  sudo ss -H -tunlp '( sport = :$port )'"
  exit 3
fi
