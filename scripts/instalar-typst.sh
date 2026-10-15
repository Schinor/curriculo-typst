#!/usr/bin/env bash
# Instala o binário oficial do Typst na versão indicada (usado pelo devcontainer).
#
# Uso: scripts/instalar-typst.sh <versao> [destino]
#   ex.: scripts/instalar-typst.sh 0.15.1 /usr/local/bin
set -euo pipefail

VERSAO="${1:?informe a versão, ex.: 0.15.1}"
DESTINO="${2:-/usr/local/bin}"

case "$(uname -m)" in
  x86_64 | amd64) ALVO="x86_64-unknown-linux-musl" ;;
  aarch64 | arm64) ALVO="aarch64-unknown-linux-musl" ;;
  *) echo "erro: arquitetura $(uname -m) não suportada" >&2; exit 1 ;;
esac

URL="https://github.com/typst/typst/releases/download/v$VERSAO/typst-$ALVO.tar.xz"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

curl -fsSL "$URL" | tar -xJ -C "$TMP"
SUDO=""
[ -w "$DESTINO" ] || SUDO="sudo"
$SUDO install -m 0755 "$TMP/typst-$ALVO/typst" "$DESTINO/typst"
typst --version
