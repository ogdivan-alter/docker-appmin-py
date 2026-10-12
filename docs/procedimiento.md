# Procedimiento Operativo Estándar: Generación, Auditoría y Publicación de la Imagen Base Docker (ogdivan/appmin-py)

## 1. Propósito y Alcance
Este documento define el procedimiento técnico estándar para la gestión del ciclo de vida de la imagen base Docker (ogdivan/appmin-py). Incluye la lectura automatizada de versiones, configuración de red/proxy, compilación del contenedor, auditoría obligatoria de seguridad mediante Docker Scout y publicación controlada en Docker Hub.

---

## 2. Prerrequisitos
* Motor de Docker (Docker Engine / Docker Desktop) instalado y en ejecución.
* CLI de Docker con el plugin Docker Scout activado (docker scout).
* Estructura de directorio con el archivo de versión en la ruta relativa ../version/version.txt.
* Credenciales activas en Docker Hub para el repositorio ogdivan/appmin-py.

---

## 3. Procedimiento Paso a Paso

### Paso 1: Verificación de la Versión
El proceso obtiene el identificador de versión (tag) directamente desde el archivo ../version/version.txt.
1. Abrir o actualizar el archivo ../version/version.txt.
2. Verificar que contenga únicamente el número de versión deseado (ejemplo: 1.0.0).

### Paso 2: Configuración de Parámetros de Red y Proxy
Durante la compilación se pueden pasar variables de entorno de red mediante --build-arg:
* PROXYLESS: Definir como N (o n) para compilar a través de proxy, o Y (o y) para salida directa a Internet.
* HTTP_PROXY: Dirección del servidor proxy HTTP (predeterminado: http://1.1.1.1:80).
* HTTPS_PROXY: Dirección del servidor proxy HTTPS (predeterminado: http://1.1.1.1:80).

### Paso 3: Compilación de la Imagen Docker

Opción A: Entornos Windows (build.bat)

```cmd
build.bat PROXYLESS=N HTTP_PROXY=http://1.1.1.1:80 HTTPS_PROXY=http://1.1.1.1:80
```

Opción B: Entornos Linux / Bash / CI/CD (build.sh)

```sh
# Ancla las rutas a su propia ubicación (puede ejecutarse desde cualquier carpeta)
# y lee la versión de version/VERSION.txt automáticamente.
./build.sh PROXYLESS=N HTTP_PROXY=http://1.1.1.1:80 HTTPS_PROXY=http://1.1.1.1:80
```

Equivalencia: `build.sh` construye con contexto en la raíz del proyecto
(`-t ogdivan/appmin-py:<versión> <raíz>`), sin parámetro `-f` porque el
`Dockerfile` se resuelve por defecto en la raíz del contexto.

---

## 4. Auditoría de Seguridad Obligatoria (Docker Scout)

Antes de enviar la imagen al registro público o privado, es requisito obligatorio ejecutar el escaneo de vulnerabilidades.

1. Inspección general de vulnerabilidades:
   docker scout quickview ogdivan/appmin-py:${VERSION}

2. Detección de vulnerabilidades Críticas y Altas con corrección disponible (fixed):
   docker scout cves --only-severity critical,high --only-fixed ogdivan/appmin-py:${VERSION}

3. Revisión de recomendaciones de actualización para la imagen base:
   docker scout recommendations ogdivan/appmin-py:${VERSION}

Criterio de Calidad y Cierre: La imagen NO debe publicarse si contiene vulnerabilidades de nivel CRITICAL o HIGH con corrección disponible (fixed). En caso de hallazgos, se deben corregir las dependencias o actualizar la imagen base en el Dockerfile y repetir la compilación.

---

## 5. Publicación y Versionado en Docker Hub

Una vez aprobada la auditoría de seguridad:

1. Autenticación en Docker Hub:
```cmd
   docker login
```

2. Publicación del Tag de Versión:
```cmd
   docker push ogdivan/appmin-py:${VERSION}
```

---

## 6. Backup y Restauración de la Imagen

El respaldo consiste en exportar la imagen construida a un archivo `.tar` (offline)
para poder reimportarla en otro equipo o tras una limpieza de imágenes.

> Todos los scripts anclan las rutas a su propia ubicación, por lo que pueden
> ejecutarse desde cualquier carpeta del sistema.

### 6.1 Respaldo (backup)

Windows (`build\win\backup.bat`):

```cmd
backup.bat
backup.bat VERSION=1.0.0
backup.bat BACKUP_DIR=D:\respaldos
```

Linux (`build/linux/backup.sh`):

```sh
./backup.sh
```

El script:

1. Determina la versión desde `version/VERSION.txt` (o el parámetro `VERSION`).
2. Crea la carpeta `backups/` en la raíz del proyecto si no existe.
3. Verifica que la imagen `ogdivan/appmin-py:<versión>` exista localmente.
4. La exporta con `docker save -o backups/ogdivan_appmin-py_<versión>.tar`.

Parámetros: `VERSION`, `IMAGE` (por defecto `ogdivan/appmin-py`) y
`BACKUP_DIR` (por defecto `backups/`).

### 6.2 Restauración (restore)

Windows (`build\win\restore.bat`):

```cmd
restore.bat
restore.bat VERSION=1.0.0
restore.bat FILE=backups\ogdivan_appmin-py_1.0.0.tar
```

Linux (`build/linux/restore.sh`):

```sh
./restore.sh
```

El script reimporta la imagen con `docker load -i <archivo>.tar`. Si no se indica
`FILE`, deduce el `.tar` a partir de `VERSION` (o `version/VERSION.txt`) e `IMAGE`.

---

## 7. Análisis Crítico y Mejores Prácticas

### Recomendaciones para Dockerfile
1. Imagen Base Estable: Cambiar python:3.14.8-slim-trixie por una versión oficial estable como python:3.12-slim-bookworm para evitar inestabilidades de versiones no lanzadas oficialmente o repositorios testing.
2. Optimización de Capas y Eliminación de Temporales: Unificar en una sola instrucción RUN la configuración temporal del proxy, apt-get update, apt-get install y la eliminación de la caché (/var/lib/apt/lists/*) y del archivo de proxy. Esto evita que los archivos temporales de proxy queden retenidos en capas intermedias del historial del contenedor.
3. Reducción de Superficie de Ataque: Evitar instalar utilidades de depuración interactiva (nano, net-tools, iputils-ping) en la imagen base de producción.

### Recomendaciones para Scripts de Construcción
1. Portabilidad a CI/CD: Proveer un script en Bash (build.sh) además del archivo Batch de Windows (build.bat) para su ejecución nativa en corredores Linux de GitHub Actions o GitLab CI.
2. Consistencia de Namespace: Asegurar el uso uniforme del usuario/repositorio (ogdivan/appmin-py) en todos los archivos del proyecto.

---

## 8. Anexo: Archivos Propuestos de Producción

### A. Dockerfile Optimizado (Dockerfile_image_base.opt)

```Dockerfile
FROM python:3.12-slim-bookworm

ENV DEBIAN_FRONTEND=noninteractive

ARG PROXYLESS=N
ARG HTTP_PROXY=http://1.1.1.1:80
ARG HTTPS_PROXY=http://1.1.1.1:80

# Configurar proxy condicionalmente, instalar paquetes y limpiar en un solo RUN
RUN if [ "$(echo $PROXYLESS | tr '[:upper:]' '[:lower:]')" != "y" ]; then \
        echo "Acquire::http::Proxy \"$HTTP_PROXY\";" > /etc/apt/apt.conf.d/apt-proxy.conf && \
        echo "Acquire::https::Proxy \"$HTTPS_PROXY\";" >> /etc/apt/apt.conf.d/apt-proxy.conf ; \
    fi && \
    apt-get update && apt-get install -y --no-install-recommends \
        locales \
    && locale-gen en_US.UTF-8 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -f /etc/apt/apt.conf.d/apt-proxy.conf

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8
```

### B. Script de Build para Linux (build.sh)
```sh 
#!/usr/bin/env bash
set -euo pipefail

VERSION_FILE="../version/version.txt"

if [ ! -f "$VERSION_FILE" ]; then
    echo "ERROR: No existe el archivo de versión en $VERSION_FILE"
    exit 1
fi

VERSION=$(tr -d '\r\n' < "$VERSION_FILE")

PROXYLESS="${PROXYLESS:-N}"
HTTP_PROXY="${HTTP_PROXY:-http://1.1.1.1:80}"
HTTPS_PROXY="${HTTPS_PROXY:-http://1.1.1.1:80}"

echo "========================================"
echo " VERSION:     $VERSION"
echo " PROXYLESS:   $PROXYLESS"
echo " HTTP_PROXY:  $HTTP_PROXY"
echo " HTTPS_PROXY: $HTTPS_PROXY"
echo "========================================"

docker build \
  --build-arg PROXYLESS="$PROXYLESS" \
  --build-arg HTTP_PROXY="$HTTP_PROXY" \
  --build-arg HTTPS_PROXY="$HTTPS_PROXY" \
  -t "ogdivan/appmin-py:${VERSION}" \
  -f Dockerfile_image_base .

echo "Build completado exitosamente para ogdivan/appmin-py:${VERSION}"
```
