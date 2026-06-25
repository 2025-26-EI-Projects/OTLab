---
title: "Documentação"
description: "Guia de instalação e execução dos laboratórios OTLab."
--------------------------------------------------------------------

# Documentação do OTLab

Esta documentação descreve os passos necessários para configurar o ambiente de execução dos laboratórios OTLab utilizando Docker. Também apresenta os comandos básicos de gestão e a estrutura geral do projeto.

## Requisitos

Antes de iniciar, certifica-te de que tens instalado:

* Git
* Docker Engine
* Docker Compose
* WSL2 (recomendado para Windows)
* Visual Studio Code (opcional)

## Instalação do Docker (Ubuntu / WSL2)

Atualizar o sistema:

```bash
sudo apt update && sudo apt upgrade -y
```

Instalar dependências:

```bash
sudo apt install -y ca-certificates curl gnupg
```

Adicionar o repositório oficial do Docker:

```bash
sudo install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
| sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
| sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

Instalar Docker Engine e Docker Compose:

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

Permitir utilização sem sudo:

```bash
sudo usermod -aG docker $USER
newgrp docker
```

Verificar instalação:

```bash
docker --version
docker compose version
```

## Clonar o Repositório

```bash
git clone https://github.com/substationworm/OTLab.git
cd OTLab
```

## Executar um Laboratório

Cada laboratório possui um script próprio de gestão.

Exemplo para o OTLab01:

```bash
cd OTLab01
chmod +x OTLab01.sh

./OTLab01.sh -start ubuntu
./OTLab01.sh -run
```

## Comandos de Gestão

| Comando                      | Descrição                                     |
| ---------------------------- | --------------------------------------------- |
| `./OTLab01.sh -start ubuntu` | Inicia o laboratório                          |
| `./OTLab01.sh -run`          | Abre um terminal no container `otlab-student` |
| `./OTLab01.sh -status`       | Mostra o estado atual dos containers          |
| `./OTLab01.sh -stop`         | Para os containers                            |
| `./OTLab01.sh -restart`      | Reinicia os containers                        |
| `./OTLab01.sh -clean`        | Remove containers, volumes e redes            |

> Nota: O nome do script muda consoante o laboratório (`OTLab02.sh`, `OTLab03.sh`, etc.).

## Estrutura do Repositório

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

A pasta `.landingPage` contém todo o código do website Hugo, incluindo layouts, conteúdo, traduções e recursos estáticos.

Cada pasta `OTLabXX` contém os ficheiros Markdown do laboratório, versões traduzidas, PDFs gerados automaticamente e scripts de execução associados ao respetivo ambiente laboratorial.


## CI/CD

O website é gerado automaticamente através de GitHub Actions.

O pipeline executa:

* Build do website Hugo;
* Geração automática dos PDFs dos laboratórios;
* Publicação automática no GitHub Pages;
* Atualização do website após alterações na branch principal.
