#!/usr/bin/env bash
#
# Restore de la imagen Docker ogdivan/appmin-py desde un .tar (docker load).
# Ancla las rutas a su propia ubicación: puede ejecutarse desde cualquier carpeta.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    cat <<'EOF'
Uso:
  restore.sh VERSION=1.0.0 IMAGE=ogdivan/appmin-py BACKUP_DIR=ruta
  restore.sh FILE=ruta/ogdivan_appmin-py_1.0.0.tar

Reimporta una imagen Docker (docker load) desde un .tar de backups.

Argumentos disponibles:
  FILE=         Ruta directa al .tar (tiene prioridad sobre lo demás)
  VERSION=      Versión/tag (por defecto: version/VERSION.txt)
  IMAGE=        Nombre de la imagen (por defecto: ogdivan/appmin-py)
  BACKUP_DIR=   Carpeta de los .tar (por defecto: backups/)

Ejemplos:
  restore.sh
  restore.sh VERSION=1.0.0
  restore.sh FILE=backups/ogdivan_appmin-py_1.0.0.tar
EOF
    exit 0
fi

# Valores por defecto
IMAGE="ogdivan/appmin-py"
BACKUP_DIR="$ROOT_DIR/backups"
FILE=""
VERSION=""

# Procesar argumentos CLAVE=valor
for arg in "$@"; do
    if [[ "$arg" != *=* ]]; then
        echo "Parametro desconocido: $arg" >&2
        exit 1
    fi
    key="${arg%%=*}"
    value="${arg#*=}"
    case "$(echo "$key" | tr '[:lower:]' '[:upper:]')" in
        FILE)       FILE="$value" ;;
        VERSION)    VERSION="$value" ;;
        IMAGE)      IMAGE="$value" ;;
        BACKUP_DIR) BACKUP_DIR="$value" ;;
        *)
            echo "Parametro desconocido: $arg" >&2
            exit 1
            ;;
    esac
    echo "Procesando argumento: $key = $value"
done

# Deducir el archivo .tar si no se indicó FILE
if [[ -z "$FILE" ]]; then
    if [[ -z "$VERSION" ]]; then
        VERSION_FILE=""
        for candidate in "$ROOT_DIR/version/version.txt" "$ROOT_DIR/version/VERSION.txt"; do
            if [[ -f "$candidate" ]]; then
                VERSION_FILE="$candidate"
                break
            fi
        done
        if [[ -z "$VERSION_FILE" ]]; then
            echo "ERROR: No existe el archivo de versión en $ROOT_DIR/version" >&2
            exit 1
        fi
        VERSION="$(tr -d ' \r\n' < "$VERSION_FILE")"
    fi
    SAFE_IMAGE="${IMAGE//\//_}"
    SAFE_IMAGE="${SAFE_IMAGE//:/_}"
    FILE="${BACKUP_DIR}/${SAFE_IMAGE}_${VERSION}.tar"
fi

echo "================================================"
echo "ARCHIVO: $FILE"
echo "================================================"

if [[ ! -f "$FILE" ]]; then
    echo "ERROR: No existe el archivo de backup: $FILE" >&2
    echo "       Ejecuta primero el backup (backup.sh)." >&2
    exit 1
fi

# Importar la imagen
echo "Importando imagen..."
if docker load -i "$FILE"; then
    echo "Restore completado."
else
    echo "ERROR: Fallo al importar la imagen." >&2
    exit 1
fi
