# DevOps Tools

Colección de scripts Bash y utilidades prácticas para tareas comunes de administración, automatización y despliegue. El objetivo es ofrecer piezas pequeñas, bien documentadas y reutilizables, que sirvan como base en proyectos DevOps.

## Características

- Scripts idempotentes siempre que es posible.
- Buenas prácticas: `set -euo pipefail`, `trap`, ayuda `-h`, códigos de salida.
- Compatibles con entornos Linux estándar.
- Sin dependencias “exóticas”; se aprovechan herramientas del sistema (curl, tar, awk, openssl, docker, etc.).

## Requisitos

- Linux (probado en Ubuntu 22.04+).
- Herramientas básicas: `bash`, `coreutils`, `awk`, `sed`, `grep`.
- Para ciertas funcionalidades:
  - `docker` y `docker compose` (para scripts relacionados).
  - `openssl` (comprobación TLS).
  - `python3` (validación YAML opcional en `validate_compose.sh`).

## Estructura

