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
git clone https://github.com/substationworm/OTLab.git
cd OTLab
./.landingPage/tools/dev.sh
```

Este script gera os mounts do Hugo (laboratórios `OTLabXX` e traduções) antes de arrancar o `hugo server`. Correr `hugo server` diretamente, sem o script, não mostra os laboratórios nem as traduções.

Abre `http://localhost:1313/` no navegador.

## Build de produção

```bash
hugo --config .landingPage/hugo.yaml,.landingPage/hugo.generated-mounts.yaml --minify --gc
```

> O ficheiro `hugo.generated-mounts.yaml` é gerado pelo `dev.sh` (local) ou pelo workflow de CI/CD (produção) — não existe no repositório por defeito.

## Configuração do GitHub Pages

Ao fazer fork deste repositório para publicar a tua própria versão do site:

### 1. Aceder às definições do repositório

1. Abrir o repositório no GitHub.
2. Clicar em **Settings** (Definições) no menu superior.
3. No menu lateral esquerdo, navegar para **Code and automation → Pages**.

### 2. Configurar o GitHub Pages

Na página Pages:

1. Em **Build and deployment → Source**, selecionar **GitHub Actions**.
2. Após a execução do workflow, o GitHub irá gerar um endereço semelhante a:

   ```text
   https://<utilizador>.github.io/<nome-do-repositorio>/
   ```

   O endereço fica visível na parte superior da página, na secção "Your site is live at ...".

### 3. Atualizar o ficheiro `hugo.yaml`

Depois de obter o URL gerado pelo GitHub Pages, atualizar a propriedade `baseURL` em `.landingPage/hugo.yaml`:

```yaml
baseURL: "https://<utilizador>.github.io/<nome-do-repositorio>/"
```

Fazer commit e push da alteração para que o site seja reconstruído com os links corretos.

### 4. Confirmar publicação

Após alguns minutos, voltar a **Settings → Pages** e confirmar que aparece a mensagem "Your site is live at https://<utilizador>.github.io/<nome-do-repositorio>/".

## Estrutura

```text
content/              Conteúdo do site (páginas estáticas, percurso de aprendizagem)
content/labs/         Índice "Laboratórios" (_index.md); OTLabXX são montados aqui pelo CI/dev.sh
layouts/              Templates Hugo
static/css/           Estilos do website
archetypes/lab.md     Template para novos laboratórios
tools/dev.sh        Gera os mounts e arranca o hugo server localmente
.github/workflows/    CI/CD para GitHub Pages
CONTRIBUTING.md       Guia de contribuição
```

## Licença

Conteúdo disponibilizado sob licença CC-BY-4.0.
