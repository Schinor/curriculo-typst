# Contribuindo

Obrigado pelo interesse! Contribuições de template, idiomas, documentação e correções são
bem-vindas.

## ⚠️ Nunca abra PR ou issue com dados reais

Este repositório é público. Use sempre a pessoa fictícia de `exemplos/dados.yaml` (ou
invente outra) para reproduzir problemas e testar mudanças. PRs com nomes, e-mails,
telefones, empresas ou fotos reais serão fechados sem merge.

## Ambiente

- Typst **0.15.1** (mesma versão do README, do devcontainer e do CI), ou use o devcontainer.
- Ative o hook de proteção uma vez por clone:
  ```bash
  git config core.hooksPath scripts
  ```

## Rodando

```bash
./scripts/build.sh exemplos/dados.yaml out pt
./scripts/build.sh exemplos/dados.yaml out en
```

O script falha se qualquer perfil não compilar ou se o Typst emitir warnings. Antes de abrir
o PR, confira visualmente os PDFs em `out/` e, se mudou o visual, atualize a imagem do README:

```bash
typst compile main.typ docs/exemplo.png --font-path fonts --pages 1 --ppi 110
```

## Padrões

- Commits pequenos, mensagens em português no padrão
  [Conventional Commits](https://www.conventionalcommits.org/pt-br/):
  `feat:`, `fix:`, `docs:`, `ci:`, `chore:`, `refactor:`.
- Comentários e mensagens de erro em português.
- Código Typst em funções pequenas e nomeadas; nada de lógica em `main.typ`.
- Campo novo no YAML? Atualize também `exemplos/dados.yaml` (preenchendo o campo),
  `schema/curriculo.schema.json`, a validação e a tabela do README.
