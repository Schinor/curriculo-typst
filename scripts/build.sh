#!/usr/bin/env bash
# Compila todos os perfis de um arquivo de dados.
#
# Uso:
#   ./scripts/build.sh [arquivo_dados] [pasta_saida] [idioma]
#
# Padrões: exemplos/dados.yaml, out, pt.
# Saída: <pasta_saida>/<perfil>.pdf (pt) ou <pasta_saida>/<perfil>-en.pdf (en).
#
# Variáveis de ambiente opcionais:
#   ROOT               raiz do projeto Typst (--root). Padrão: a pasta deste template.
#                      O arquivo de dados precisa estar dentro de ROOT. Use ROOT=. ao
#                      chamar a partir de um repositório que tem o template como submodule.
#   TYPST              binário do Typst (padrão: typst)
#   CURRICULO_COR      cor de destaque, ex.: "#7a1f3d"
#   CURRICULO_FOTO     "nao" para ocultar a foto
#   PERMITIR_WARNINGS  "1" para não falhar quando o Typst emitir warnings
set -euo pipefail

TEMPLATE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DADOS="${1:-exemplos/dados.yaml}"
SAIDA="${2:-out}"
IDIOMA="${3:-pt}"
ROOT="$(cd "${ROOT:-$TEMPLATE_DIR}" && pwd)"
TYPST="${TYPST:-typst}"

erro() { echo "erro: $*" >&2; exit 1; }

command -v "$TYPST" >/dev/null || erro "Typst não encontrado (instale a versão indicada no README)"
[ -f "$DADOS" ] || erro "arquivo de dados \"$DADOS\" não encontrado"

# O Typst só lê arquivos dentro de --root; caminhos com "/" são relativos a ele.
DADOS_ABS="$(cd "$(dirname "$DADOS")" && pwd)/$(basename "$DADOS")"
case "$DADOS_ABS" in
  "$ROOT"/*) DADOS_TYPST="/${DADOS_ABS#"$ROOT"/}" ;;
  *) erro "\"$DADOS\" está fora da raiz \"$ROOT\"; ajuste a variável ROOT" ;;
esac

# Typst entende caminhos relativos a partir do arquivo compilado, não do diretório atual.
MAIN_REL="${TEMPLATE_DIR#"$ROOT"/}/main.typ"
[ "$TEMPLATE_DIR" = "$ROOT" ] && MAIN_REL="main.typ"

COMUNS=(--root "$ROOT" --font-path "$TEMPLATE_DIR/fonts" --input "dados=$DADOS_TYPST")

# Ids dos perfis, lidos pelo próprio Typst (sem depender de yq).
PERFIS_JSON="$("$TYPST" eval "yaml(\"$DADOS_TYPST\").perfis.keys()" --root "$ROOT")" \
  || erro "não foi possível ler \"perfis\" de $DADOS"
mapfile -t PERFIS < <(echo "$PERFIS_JSON" | tr -d '[]"' | tr ',' '\n' | sed '/^$/d')
[ "${#PERFIS[@]}" -gt 0 ] || erro "nenhum perfil definido em $DADOS"

EXTRAS=()
[ -n "${CURRICULO_COR:-}" ] && EXTRAS+=(--input "cor=$CURRICULO_COR")
[ -n "${CURRICULO_FOTO:-}" ] && EXTRAS+=(--input "foto=$CURRICULO_FOTO")

mkdir -p "$SAIDA"
SUFIXO=""
[ "$IDIOMA" != "pt" ] && SUFIXO="-$IDIOMA"

falhas=0
for perfil in "${PERFIS[@]}"; do
  destino="$SAIDA/$perfil$SUFIXO.pdf"
  if log="$("$TYPST" compile "$ROOT/$MAIN_REL" "$destino" "${COMUNS[@]}" "${EXTRAS[@]}" \
      --input "perfil=$perfil" --input "idioma=$IDIOMA" 2>&1)"; then
    if [ -n "$log" ] && grep -q "warning" <<<"$log" && [ "${PERMITIR_WARNINGS:-}" != "1" ]; then
      echo "✗ $destino (warnings)" >&2
      echo "$log" >&2
      falhas=$((falhas + 1))
    else
      echo "✓ $destino"
    fi
  else
    echo "✗ $perfil" >&2
    echo "$log" >&2
    falhas=$((falhas + 1))
  fi
done

[ "$falhas" -eq 0 ] || erro "$falhas perfil(is) com problema"
