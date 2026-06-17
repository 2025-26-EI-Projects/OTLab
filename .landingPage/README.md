# OTLab — Website e Documentação

Website público e documentação estruturada para o projeto OTLab, uma plataforma educativa open-source para cibersegurança de Tecnologias Operacionais (OT) e Sistemas de Controlo Industrial (ICS).

## Objetivo

Este repositório implementa o Módulo 1 — Landing Page e Documentação do Projeto OTLab:

- Website responsivo com Hugo e GitHub Pages;
- Documentação estruturada e navegável;
- Páginas dedicadas para 13 laboratórios;
- Diagramas de topologia com Mermaid.js;
- Guia de contribuição;
- Template de laboratório;
- Pipeline CI/CD com GitHub Actions.

## Executar localmente

```bash
git clone <URL_DO_REPOSITORIO>
cd <NOME_DO_REPOSITORIO>
hugo server -D
```

Abre `http://localhost:1313/` no navegador.

## Build de produção

```bash
hugo --minify --gc
```

## Estrutura

```text
content/              Conteúdo do site e laboratórios
layouts/              Templates Hugo
static/css/           Estilos do website
archetypes/lab.md     Template para novos laboratórios
.github/workflows/    CI/CD para GitHub Pages
CONTRIBUTING.md       Guia de contribuição
```

## Licença

Conteúdo disponibilizado sob licença CC-BY-4.0.
