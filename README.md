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

```powershell
.\backup.bat    # Windows (build\win)
.\restore.bat
```

```bash
./backup.sh     # Debian (build/linux)
./restore.sh
```

<!-- Describe aquí qué respalda y restaura cada script -->

## 🏷️ Imagen

- Nombre: `ogdivan/appmin-py`
- Tag actual: `1.0.0` (definido en `version/VERSION.txt`)

## 📚 Documentación

Ver [`docs/procedimiento.md`](docs/procedimiento.md) para el procedimiento detallado.

## 🛠️ Solución de problemas

| Problema | Posible causa / solución |
|----------|--------------------------|
| `No existe el archivo de versión` | Revisa la ruta y el nombre de `version/VERSION.txt` (en Linux distingue mayúsculas). |
| `Parametro desconocido` | Solo se aceptan `PROXYLESS`, `HTTP_PROXY` y `HTTPS_PROXY`. |
| Build falla por red | Verifica los valores de proxy o usa `PROXYLESS=Y` si no hay proxy. |
| `docker: command not found` | Docker no está instalado o no está en el PATH. |
| `permission denied` (Debian) | Agrega el usuario al grupo `docker` o usa `sudo`. |

## 🗺️ Próximos pasos (ideas)

- [ ] Añadir `docker-compose.yml`
- [ ] Añadir `.dockerignore`
- [ ] Pipeline CI/CD (GitHub Actions)

## 📄 Licencia

_Por definir (ej. MIT)._
