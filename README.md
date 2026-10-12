# appmin-py

> Proyecto de imagen base Docker con soporte Python disponible para construir imagenes adaptadas para proyectos con requerimientos específicos.

## 🎯 Objetivo

<!-- Ajusta a tu caso -->
- Habilitar una imagen con el soporte mínimo necesario con Python.
- Asistir el ciclo **build → backup → restore** con scripts reproducibles.
- Mantener scripts equivalentes para Windows y Linux (Debian).
- Soportar construcción tanto con proxy como sin proxy (entornos corporativos).

## 💻 Sistemas operativos soportados

| OS | Shell | Scripts |
|----|-------|---------|
| Windows 10/11 | CMD / PowerShell | `build/win/*.bat` |
| Linux Debian | Bash | `build/linux/*.sh` |

## 🧱 Entorno principal

| Componente | Tecnología | Versión |
|------------|-----------|---------|
| Contenedores | Docker Engine / Docker Desktop |  |
| Framework / runtime | Python | 3.14.8 |

## 📁 Estructura del proyecto

```
appmin-py/
├── build/
│   ├── linux/
│   │   ├── backup.sh
│   │   ├── build.sh
│   │   └── restore.sh
│   └── win/
│       ├── backup.bat
│       ├── build.bat
│       └── restore.bat
├── docs/
│   └── procedimiento.md    # Procedimiento detallado
├── version/
│   └── VERSION.txt         # Versión de la imagen (fuente única)
├── .gitignore
├── Dockerfile
└── README.md
```

## ✅ Requisitos previos

- Docker instalado y en ejecución (`docker --version`).
- Windows: CMD o PowerShell. Debian: Bash y permisos para usar Docker.
- Archivo `version/VERSION.txt` con la versión a construir (ej. `1.0.0`).

## 🚀 Uso rápido

### 1. Construir la imagen

La versión se lee de `version/VERSION.txt` y la imagen resultante es `ogdivan/appmin-py:<versión>` (actualmente `1.0.0`).

```powershell
# Windows
cd build\win
.\build.bat
.\build.bat --help
```

```bash
# Debian
cd build/linux
./build.sh
./build.sh --help
```

> Los scripts anclan las rutas a su propia ubicación, por lo que también puedes
> ejecutarlos desde cualquier carpeta, por ejemplo:
> `F:\...\appmin-py\build\win\build.bat`.

#### Parámetros (todos opcionales, formato `CLAVE=valor`)

| Parámetro | Valor por defecto | Descripción |
|-----------|-------------------|-------------|
| `PROXYLESS` | `N` | `Y` o `N` (no distingue mayúsculas). Se pasa como `--build-arg` al Dockerfile. |
| `HTTP_PROXY` | `http://1.1.1.1:80` | Proxy HTTP usado durante el build. |
| `HTTPS_PROXY` | `http://1.1.1.1:80` | Proxy HTTPS usado durante el build. |

Ejemplo:

```powershell
.\build.bat PROXYLESS=N HTTP_PROXY=http://10.0.0.1:8080 HTTPS_PROXY=http://10.0.0.1:8080
```

El script valida los argumentos y termina con código de salida distinto de 0 si hay un parámetro desconocido, `PROXYLESS` inválido o falla el build.

### 2. Ejecutar el contenedor

```bash
docker run -it --name appmin-py ogdivan/appmin-py:1.0.0 bash
```

<!-- Ajusta el puerto según tu Dockerfile -->

### 3. Backup y restore

Estos scripts exportan e importan la **imagen Docker** con `docker save` / `docker load`.
Al igual que `build.bat`, se pueden ejecutar desde cualquier carpeta: resuelven la raíz
del proyecto a partir de su propia ubicación.

```powershell
# Windows (build\win)
.\backup.bat     # Exporta ogdivan/appmin-py:<versión> a backups\ogdivan_appmin-py_<versión>.tar
.\restore.bat    # Reimporta la imagen desde el .tar correspondiente
```

```bash
# Debian
./backup.sh
./restore.sh
```

`backup.bat` crea la carpeta `backups\` en la raíz del proyecto si no existe
(está ignorada por git para no versionar los `.tar`).

#### Parámetros de `backup.bat` (todos opcionales, formato `CLAVE=valor`)

| Parámetro | Valor por defecto | Descripción |
|-----------|-------------------|-------------|
| `VERSION` | contenido de `version/VERSION.txt` | Tag de la imagen a exportar. |
| `IMAGE` | `ogdivan/appmin-py` | Nombre de la imagen. |
| `BACKUP_DIR` | `backups` (raíz del proyecto) | Carpeta destino del `.tar`. |

Ejemplo:

```powershell
.\backup.bat VERSION=1.0.0
.\backup.bat BACKUP_DIR=D:\respaldos
```

#### Parámetros de `restore.bat` (todos opcionales, formato `CLAVE=valor`)

| Parámetro | Valor por defecto | Descripción |
|-----------|-------------------|-------------|
| `FILE` | — | Ruta directa al `.tar` (tiene prioridad sobre los demás). |
| `VERSION` | contenido de `version/VERSION.txt` | Versión de la que se deduce el `.tar`. |
| `IMAGE` | `ogdivan/appmin-py` | Nombre de la imagen. |
| `BACKUP_DIR` | `backups` (raíz del proyecto) | Carpeta de los `.tar`. |

Ejemplo:

```powershell
.\restore.bat VERSION=1.0.0
.\restore.bat FILE=backups\ogdivan_appmin-py_1.0.0.tar
```

Ambos terminan con código de salida distinto de 0 ante parámetros desconocidos,
archivo/imagen inexistente o fallo de Docker.

## 🏷️ Imagen

- Nombre: `ogdivan/appmin-py`
- Tag actual: `1.0.0` (definido en `version/VERSION.txt`)

## 📚 Documentación

Ver [`docs/procedimiento.md`](docs/procedimiento.md) para el procedimiento detallado.

## 🛠️ Solución de problemas

| Problema | Posible causa / solución |
|----------|--------------------------|
| `No existe el archivo de versión` | Revisa la ruta y el nombre de `version/VERSION.txt` (en Linux distingue mayúsculas). |
| `Parametro desconocido` | `build` acepta `PROXYLESS`, `HTTP_PROXY`, `HTTPS_PROXY`; `backup`/`restore` aceptan `VERSION`, `IMAGE`, `BACKUP_DIR` (y `restore` además `FILE`). |
| Build falla por red | Verifica los valores de proxy o usa `PROXYLESS=Y` si no hay proxy. |
| `La imagen ... no existe localmente` (backup) | Ejecuta primero el build (`build.bat`) para generar la imagen antes de respaldarla. |
| `No existe el archivo de backup` (restore) | Ejecuta primero `backup.bat` o indica la ruta con `FILE=...`. |
| `docker: command not found` | Docker no está instalado o no está en el PATH. |
| `permission denied` (Debian) | Agrega el usuario al grupo `docker` o usa `sudo`. |

## 🗺️ Próximos pasos (ideas)

- [ ] Añadir `docker-compose.yml`
- [ ] Añadir `.dockerignore`
- [ ] Pipeline CI/CD (GitHub Actions)

## 📄 Licencia

_Por definir (ej. MIT)._
