#!/bin/bash
set -e

# ─── build.sh ────────────────────────────────────────────────────────────────
# Cria os ZIPs necessários para o Terraform:
#   build/utils_layer.zip  → Lambda Layer com src/utils/
#   build/lambda.zip       → Lambda Function com src/normal python/main.py
# ─────────────────────────────────────────────────────────────────────────────

ROOT="$(cd "$(dirname "$0")" && pwd)"
BUILD="$ROOT/build"

rm -rf "$BUILD" && mkdir -p "$BUILD"

# ── 1. utils_layer.zip ──────────────────────────────────────────────────────
# Estrutura obrigatória de uma Lambda Layer:
#   python/
#     utils/
#       __init__.py
#       logging_utils.py
#
# Com este layout, o import `from utils.logging_utils import setup_logger`
# funciona dentro da Lambda exactamente como funciona localmente.

echo "→ A construir utils_layer.zip..."
LAYER_TMP="$BUILD/layer_tmp"
mkdir -p "$LAYER_TMP/python/utils"
cp "$ROOT/src/utils/__init__.py"    "$LAYER_TMP/python/utils/"
cp "$ROOT/src/utils/logging_utils.py" "$LAYER_TMP/python/utils/"

cd "$LAYER_TMP"
zip -r "$BUILD/utils_layer.zip" python/
cd "$ROOT"
rm -rf "$LAYER_TMP"
echo "   ✓ build/utils_layer.zip criado"

# ── 2. lambda.zip ────────────────────────────────────────────────────────────
# Apenas o main.py — a utils layer é montada automaticamente em /opt/python/

echo "→ A construir lambda.zip..."
LAMBDA_TMP="$BUILD/lambda_tmp"
mkdir -p "$LAMBDA_TMP"
cp "$ROOT/src/normal python/main.py" "$LAMBDA_TMP/"

cd "$LAMBDA_TMP"
zip -r "$BUILD/lambda.zip" main.py
cd "$ROOT"
rm -rf "$LAMBDA_TMP"
echo "   ✓ build/lambda.zip criado"

echo ""
echo "Build concluído:"
ls -lh "$BUILD"
