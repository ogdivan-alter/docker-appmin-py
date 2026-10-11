FROM python:3.14.8-slim-trixie

# Evitar preguntas interactivas
ENV DEBIAN_FRONTEND=noninteractive

# Argumentos del build
ARG PROXYLESS=N
ARG HTTP_PROXY=http://1.1.1.1:80
ARG HTTPS_PROXY=http://1.1.1.1:80

# Mostrar valores para depuración
RUN echo "PROXYLESS=$PROXYLESS" && \
    echo "HTTP_PROXY=$HTTP_PROXY" && \
    echo "HTTPS_PROXY=$HTTPS_PROXY"

# Si NO es proxyless, configurar proxy para apt
RUN if [ "$(echo $PROXYLESS | tr '[:upper:]' '[:lower:]')" != "y" ]; then \
        echo "Acquire::http::Proxy \"$HTTP_PROXY\";" > /etc/apt/apt.conf.d/apt-proxy.conf && \
        echo "Acquire::https::Proxy \"$HTTPS_PROXY\";" >> /etc/apt/apt.conf.d/apt-proxy.conf ; \
    else \
        echo "Sin proxy para el build" ; \
    fi
# 
# Instalación de herramientas esenciales
RUN apt-get update && apt-get install -y \
    nano \
    net-tools \
    iputils-ping \
    locales \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Configuración de locales
RUN locale-gen en_US.UTF-8

RUN rm -f /etc/apt/apt.conf.d/apt-proxy.conf
RUN PROXYLESS=Y
RUN HTTP_PROXY=
RUN HTTPS_PROXY=

# Scripts de inicialización
# COPY scripts/entrypoint.sh /entrypoint.sh
# COPY scripts/init-proxy.sh /init-proxy.sh
# COPY scripts/setup-env.sh /setup-env.sh

# RUN chmod +x /entrypoint.sh /init-proxy.sh /setup-env.sh

# ENTRYPOINT ["/entrypoint.sh"]