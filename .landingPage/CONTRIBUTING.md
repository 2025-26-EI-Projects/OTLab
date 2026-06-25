# Guia de Contribuição — OTLab

Obrigado por contribuires para o OTLab!

Este projeto segue uma abordagem **Docs-as-Code**, onde laboratórios, documentação e scripts são mantidos no repositório e revistos através de Pull Requests.

---

# Índice

* Pré-requisitos
* Configuração Inicial
* Estrutura do Projeto
* Adicionar um Novo Laboratório
* Alterar um Laboratório Existente
* Estrutura de Ficheiros
* Frontmatter e Metadados
* Traduções e PDFs
* Boas Práticas
* Abrir um Pull Request
* Licença

---

# Pré-requisitos

| Ferramenta              | Versão mínima | Utilização                           |
|-------------------------|---------------|--------------------------------------|
| Git                     | 2.x           | Versionamento                        |
| Hugo Extended           | Última versão | Pré-visualização local               |
| Docker + Docker Compose | 24.x          | Execução dos laboratórios            |
| Bash                    | —             | Geração dos mounts do Hugo (`tools/dev.sh`) |

---
# Configuração Inicial

## 1. Clonar o repositório

```bash
git clone https://github.com/substationworm/OTLab.git

cd OTLab
```

Verificar o remote configurado:

```bash
git remote -v
```

---

## 2. Gerar o ficheiro de mounts do Hugo

O ficheiro `.landingPage/hugo.generated-mounts.yaml` **não é armazenado no repositório** e encontra-se listado no `.gitignore`.

Para testar a landing page localmente, é necessário gerar este ficheiro após efetuar o clone do repositório.

Executar:

```bash
./.landingPage/tools/dev.sh
```

Este comando gera automaticamente:

```text
.landingPage/hugo.generated-mounts.yaml
```

e arranca o `hugo server` de seguida. Sempre que for adicionado, removido ou renomeado um laboratório (`OTLabXX`), basta correr o script novamente.

---

## 3. Executar a landing page localmente

O passo anterior já arranca o servidor. Para o fazer manualmente noutra ocasião (com o ficheiro de mounts já gerado):

```bash
hugo server --config .landingPage/hugo.yaml,.landingPage/hugo.generated-mounts.yaml -D
```

---

## 4. Abrir no navegador

```text
http://localhost:1313/
```

ou, caso o `baseURL` esteja configurado para GitHub Pages:

```text
http://localhost:1313/OTLab/
```
> [!NOTE]
> O ficheiro `.landingPage/hugo.generated-mounts.yaml` é um artefacto gerado localmente e não deve ser adicionado ao repositório.
---

# Estrutura do Projeto

A estrutura atual do projeto encontra-se organizada da seguinte forma:

```text
ExemploPagina.github.io/
│
├── .github/
│   └── workflows/
│       └── hugo.yml
│
├── .landingPage/
│   ├── archetypes/
│   ├── content/
│   ├── i18n/
│   ├── layouts/
│   ├── tools/
│   ├── static/
│   ├── hugo.yaml
│   ├── README.md
│   └── CONTRIBUTING.md
│
├── OTLab01/
├── OTLab02/
├── OTLab03/
├── ...
├── OTLab13/
│
└── README.md
```

A pasta `.landingPage` contém todo o código da landing page Hugo.

Cada pasta `OTLabXX` contém o conteúdo e os recursos associados a um laboratório específico.

---

# Adicionar um Novo Laboratório

O workflow do GitHub Actions deteta automaticamente novos laboratórios presentes na raiz do repositório.

## Passo 1 — Criar a pasta do laboratório

Utilizar a convenção:

```text
OTLabXX
```

Exemplo:

```text
OTLab14
```

---

## Passo 2 — Criar a estrutura mínima

```text
OTLab14/
│
├── index.md
├── index.en.md
├── index.es.md
│
├── OTLab14.md
├── OTLab14-EN.md
├── OTLab14-ES.md
│
├── OTLab14.sh
└── OTLab14-Offline.sh
```

Os ficheiros `.sh` são opcionais.

---

## Passo 3 — Preencher o conteúdo

O ficheiro principal do laboratório é:

```text
OTLab14.md
```

As restantes versões devem conter as traduções para Inglês e Espanhol, respeitando o sufixo em maiúsculas:

```text
OTLab14-EN.md
OTLab14-ES.md
```

---

## Passo 4 — Criar uma branch

```bash
git checkout -b lab/OTLab14

git add .

git commit -m "feat: adicionar OTLab14"

git push origin lab/OTLab14
```

---

# Alterar um Laboratório Existente

Para alterar um laboratório existente:

```bash
git checkout -b fix/OTLab01
```

Editar os ficheiros pretendidos:

```text
OTLab01/
├── index.md
├── OTLab01.md
```

Depois:

```bash
git add .

git commit -m "fix: corrigir OTLab01"

git push origin fix/OTLab01
```

---

# Estrutura de Ficheiros de um Laboratório

Cada laboratório deve seguir a seguinte organização:

```text
OTLabXX/
│
├── index.md
├── index.en.md
├── index.es.md
│
├── OTLabXX.md
├── OTLabXX-EN.md
├── OTLabXX-ES.md
│
├── OTLabXX.pdf
├── OTLabXX-EN.pdf
├── OTLabXX-ES.pdf
│
├── OTLabXX.sh
└── OTLabXX-Offline.sh
```

---

## Frontmatter e Metadados

O frontmatter controla os metadados utilizados na landing page, na listagem de laboratórios e na organização do skill path.

Todos os laboratórios devem seguir o mesmo esquema para garantir consistência na navegação e progressão.

### Estrutura padrão

```yaml
---
title: "Título do laboratório"
description: "Descrição clara do objetivo do laboratório."
categories: ["Laboratórios"]
difficulty: "Iniciante | Intermédio | Avançado (escolher um)"
tags:
  - TAG1
  - TAG2
  - TAG3
estimated_time: "60 min"
level: 0
area: "discovery"
draft: false
---
```

## Campos do Frontmatter

| Campo           | Obrigatório | Descrição                                   |
|----------------|------------|---------------------------------------------|
| title          | Sim        | Título do laboratório                       |
| description    | Sim        | Resumo apresentado na landing page          |
| categories     | Sim        | Categoria do conteúdo (ex: Laboratórios)    |
| difficulty     | Sim        | Iniciante, Intermédio ou Avançado          |
| tags           | Sim        | Tecnologias e protocolos abordados         |
| estimated_time | Sim        | Tempo estimado de execução                 |
| level          | Sim        | Ordem no skill path (0, 1, 2, 3...)        |
| area           | Sim        | Área técnica (discovery, exploitation, etc)|
| draft          | Opcional   | Se true, o laboratório não é publicado     |
---

# Traduções e PDFs

O projeto suporta três idiomas:

* Português
* Inglês
* Espanhol

Cada laboratório deve possuir:

```text
index.md
index.en.md
index.es.md
```

e

```text
OTLabXX.md
OTLabXX-EN.md
OTLabXX-ES.md
```

As traduções devem ser feitas manualmente; não existe atualmente nenhuma integração automática de tradução no workflow.

---

## PDFs

Os PDFs são gerados automaticamente pelo GitHub Actions a partir dos ficheiros Markdown.

São produzidas automaticamente as versões:

```text
OTLabXX.pdf
OTLabXX-EN.pdf
OTLabXX-ES.pdf
```

Não é necessário gerar PDFs manualmente.

---

# Boas Práticas

* Escrever instruções reproduzíveis e testadas localmente.
* Utilizar Docker sempre que possível.
* Utilizar nomes consistentes para serviços, redes e containers.
* Incluir diagramas Mermaid quando apropriado.
* Utilizar blocos de aviso para operações potencialmente destrutivas.

Exemplo:

```md
> [!WARNING]
> Esta operação remove todos os dados existentes.
```

* Manter foco educativo e defensivo.
* Não incluir credenciais, palavras-passe ou chaves de API.
* Respeitar a convenção de nomenclatura `OTLabXX`.

---

# Abrir um Pull Request

Antes de abrir um Pull Request:

```bash
./.landingPage/tools/dev.sh
```

Confirmar que:

* O site compila sem erros.
* Os links funcionam corretamente.
* As imagens são carregadas.
* As traduções estão atualizadas.
* O laboratório aparece corretamente na landing page.

Depois:

1. Abrir o Pull Request para a branch `main`.
2. Descrever as alterações efetuadas.
3. Indicar o contexto OT/ICS relevante.
4. Adicionar passos de validação quando aplicável.
5. Aguardar revisão da equipa.

---

# Licença

Ao contribuires para este projeto, aceitas que o teu conteúdo seja disponibilizado sob a licença **Creative Commons Attribution 4.0 International (CC BY 4.0)**, salvo indicação em contrário.