---
title: "Documentation"
description: "Installation and execution guide for OTLab laboratories."
-----------------------------------------------------------------------

# OTLab Documentation

This documentation describes the steps required to configure the environment for running OTLab laboratories using Docker. It also presents the basic management commands and the overall project structure.

## Requirements

Before starting, make sure you have installed:

* Git
* Docker Engine
* Docker Compose
* WSL2 (recommended for Windows users)
* Visual Studio Code (optional)

## Docker Installation (Ubuntu / WSL2)

Update the system:

```bash
sudo apt update && sudo apt upgrade -y
```

Install dependencies:

```bash
sudo apt install -y ca-certificates curl gnupg
```

Add the official Docker repository:

```bash
sudo install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
| sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
| sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

Install Docker Engine and Docker Compose:

```bash
sudo apt update

sudo apt install -y \
docker-ce \
docker-ce-cli \
containerd.io \
docker-buildx-plugin \
docker-compose-plugin
```

Start Docker:

```bash
sudo service docker start
```

Allow Docker to run without sudo:

```bash
sudo usermod -aG docker $USER
newgrp docker
```

Verify installation:

```bash
docker --version
docker compose version
```

## Clone the Repository

```bash
git clone https://github.com/substationworm/OTLab.git
cd OTLab
```

## Run a Laboratory

Each laboratory includes its own management script.

Example for OTLab01:

```bash
cd OTLab01
chmod +x OTLab01.sh

./OTLab01.sh -start ubuntu
./OTLab01.sh -run
```

## Management Commands

| Command                      | Description                                           |
| ---------------------------- | ----------------------------------------------------- |
| `./OTLab01.sh -start ubuntu` | Starts the laboratory                                 |
| `./OTLab01.sh -run`          | Opens a terminal inside the `otlab-student` container |
| `./OTLab01.sh -status`       | Displays the current container status                 |
| `./OTLab01.sh -stop`         | Stops the containers                                  |
| `./OTLab01.sh -restart`      | Restarts the containers                               |
| `./OTLab01.sh -clean`        | Removes containers, volumes, and networks             |

> Note: The script name changes depending on the laboratory (`OTLab02.sh`, `OTLab03.sh`, etc.).

## Repository Structure

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

The `.landingPage` folder contains all Hugo website code, including layouts, content, translations and static assets.

Each `OTLabXX` folder contains the laboratory Markdown files, translated versions, automatically generated PDFs and execution scripts associated with the corresponding laboratory environment.


## CI/CD

The website is automatically generated using GitHub Actions.

The pipeline performs:

* Hugo website build;
* Automatic generation of laboratory PDFs;
* Automatic deployment to GitHub Pages;
* Website updates after changes are pushed to the main branch.
