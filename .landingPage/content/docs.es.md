---
title: "Documentación"
description: "Guía de instalación y ejecución de los laboratorios OTLab."
-------------------------------------------------------------------------

# Documentación de OTLab

Esta documentación describe los pasos necesarios para configurar el entorno de ejecución de los laboratorios OTLab utilizando Docker. También presenta los comandos básicos de administración y la estructura general del proyecto.

## Requisitos

Antes de comenzar, asegúrate de tener instalado:

* Git
* Docker Engine
* Docker Compose
* WSL2 (recomendado para usuarios de Windows)
* Visual Studio Code (opcional)

## Instalación de Docker (Ubuntu / WSL2)

Actualizar el sistema:

```bash
sudo apt update && sudo apt upgrade -y
```

Instalar dependencias:

```bash
sudo apt install -y ca-certificates curl gnupg
```

Agregar el repositorio oficial de Docker:

```bash
sudo install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
| sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
| sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

Instalar Docker Engine y Docker Compose:

```bash
sudo apt update

sudo apt install -y \
docker-ce \
docker-ce-cli \
containerd.io \
docker-buildx-plugin \
docker-compose-plugin
```

Iniciar Docker:

```bash
sudo service docker start
```

Permitir el uso de Docker sin sudo:

```bash
sudo usermod -aG docker $USER
newgrp docker
```

Verificar la instalación:

```bash
docker --version
docker compose version
```

## Clonar el Repositorio

```bash
git clone https://github.com/2025-26-EI-Projects/OTLab.git
cd OTLab
```

## Ejecutar un Laboratorio

Cada laboratorio dispone de su propio script de administración.

Ejemplo para OTLab01:

```bash
cd OTLab01
chmod +x OTLab01.sh

./OTLab01.sh -start ubuntu
./OTLab01.sh -run
```

## Comandos de Administración

| Comando                      | Descripción                                             |
| ---------------------------- | ------------------------------------------------------- |
| `./OTLab01.sh -start ubuntu` | Inicia el laboratorio                                   |
| `./OTLab01.sh -run`          | Abre una terminal dentro del contenedor `otlab-student` |
| `./OTLab01.sh -status`       | Muestra el estado actual de los contenedores            |
| `./OTLab01.sh -stop`         | Detiene los contenedores                                |
| `./OTLab01.sh -restart`      | Reinicia los contenedores                               |
| `./OTLab01.sh -clean`        | Elimina contenedores, volúmenes y redes                 |

> Nota: El nombre del script cambia según el laboratorio (`OTLab02.sh`, `OTLab03.sh`, etc.).

## Estructura del Repositorio

```text
├── .github/
│   └── workflows/
│       └── hugo.yml
│
├── .landingPage/
│   ├── archetypes/
│   ├── content/
│   ├── i18n/
│   ├── layouts/
│   ├── static/
│   ├── hugo.yaml
│   ├── README.md
│   └── CONTRIBUTING.md
│
├── OTLab01/
├── OTLab02/
├── OTLab03/
├── OTLab04/
├── OTLab05/
├── OTLab06/
├── OTLab07/
├── OTLab08/
├── OTLab09/
├── OTLab10/
├── OTLab11/
├── OTLab12/
├── OTLab13/
```

La carpeta `.landingPage` contiene todo el código del sitio web Hugo, incluidos los layouts, contenidos, traducciones y recursos estáticos.

Cada carpeta `OTLabXX` contiene los archivos Markdown del laboratorio, las versiones traducidas, los PDF generados automáticamente y los scripts de ejecución asociados al entorno de laboratorio correspondiente.


## CI/CD

El sitio web se genera automáticamente mediante GitHub Actions.

El pipeline realiza:

* Compilación del sitio web Hugo;
* Generación automática de los PDF de los laboratorios;
* Publicación automática en GitHub Pages;
* Actualización del sitio web tras cambios en la rama principal.
