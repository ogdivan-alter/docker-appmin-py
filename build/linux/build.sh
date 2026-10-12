#!/usr/bin/env bash
#
# Build de la imagen Docker ogdivan/appmin-py.
# Ancla las rutas a su propia ubicación: puede ejecutarse desde cualquier carpeta.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    cat <<'EOF'
Uso:
  build.sh PROXYLESS=N HTTP_PROXY=http://1.1.1.1:80 HTTPS_PROXY=http://1.1.1.1:80

Argumentos disponibles:
  PROXYLESS=N     Desactiva proxy si es N (no sensible a mayúsculas)
  HTTP_PROXY=     Proxy HTTP para el build
  HTTPS_PROXY=    Proxy HTTPS para el build

Ejemplos:
  build.sh
  build.sh PROXYLESS=N HTTP_PROXY=http://10.0.0.1:8080 HTTPS_PROXY=http://10.0.0.1:8080
EOF
    exit 0
fi

# Valores por defecto (equivalentes a build.bat; se sobrescriben por argumento)
PROXYLESS="N"
HTTP_PROXY="http://1.1.1.1:80"
HTTPS_PROXY="http://1.1.1.1:80"

# Procesar argumentos CLAVE=valor
for arg in "$@"; do
    if [[ "$arg" != *=* ]]; then
        echo "Parametro desconocido: $arg" >&2
        exit 1
    fi
    key="${arg%%=*}"
    value="${arg#*=}"
    case "$(echo "$key" | tr '[:lower:]' '[:upper:]')" in
        PROXYLESS)   PROXYLESS="$value" ;;
        HTTP_PROXY)  HTTP_PROXY="$value" ;;
        HTTPS_PROXY) HTTPS_PROXY="$value" ;;
        *)
            echo "Parametro desconocido: $arg" >&2
            exit 1
            ;;
    esac
    echo "Procesando argumento: $key = $value"
done

# Validación sintáctica
LOWER="$(echo "$PROXYLESS" | tr '[:upper:]' '[:lower:]')"
if [[ "$LOWER" != "y" && "$LOWER" != "n" ]]; then
    echo "ERROR: PROXYLESS debe ser Y o N" >&2
    exit 1
fi

# Leer versión (acepta version.txt o VERSION.txt)
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
VERSION="$(tr -d '\r\n' < "$VERSION_FILE")"

echo "================================================"
echo "VERSION:     $VERSION"
echo "PROXYLESS:   $PROXYLESS"
echo "HTTP_PROXY:  $HTTP_PROXY"
echo "HTTPS_PROXY: $HTTPS_PROXY"
echo "================================================"

# Ejecutar docker build
echo "Ejecutando docker build..."
if docker build \
    --build-arg PROXYLESS="$PROXYLESS" \
    --build-arg HTTP_PROXY="$HTTP_PROXY" \
    --build-arg HTTPS_PROXY="$HTTPS_PROXY" \
    -t "ogdivan/appmin-py:${VERSION}" \
    "$ROOT_DIR"; then
    echo "Build completado exitosamente."
else
    echo "Build fallo." >&2
    exit 1
fi
