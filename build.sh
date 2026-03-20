#!/bin/bash
set -e

# ─── build.sh ────────────────────────────────────────────────────────────────
# 1. Cria os ZIPs localmente
# 2. Faz upload para S3 (o bucket já existe de deploys anteriores)
#
# Uso no CI:   bash build.sh <bucket_name>
# Uso local:   bash build.sh dev-eu-north-1-buildrun-pipeline
# ─────────────────────────────────────────────────────────────────────────────

BUCKET_NAME="${1}"

if [ -z "$BUCKET_NAME" ]; then
  echo "Uso: bash build.sh <bucket_name>"
  exit 1
fi

ROOT="$(cd "$(dirname "$0")" && pwd)"
BUILD="$ROOT/build"

rm -rf "$BUILD" && mkdir -p "$BUILD"

# ── 1. utils_layer.zip ──────────────────────────────────────────────────────
# Estrutura da Layer: python/utils/ → disponível como `from utils.X import Y`

echo "→ A construir utils_layer.zip..."
LAYER_TMP="$BUILD/layer_tmp"
mkdir -p "$LAYER_TMP/python/utils"
cp "$ROOT/src/utils/__init__.py"      "$LAYER_TMP/python/utils/"
cp "$ROOT/src/utils/logging_utils.py" "$LAYER_TMP/python/utils/"
cd "$LAYER_TMP" && zip -r "$BUILD/utils_layer.zip" python/ && cd "$ROOT"
rm -rf "$LAYER_TMP"
echo "   ✓ build/utils_layer.zip criado"

# ── 2. lambda.zip ────────────────────────────────────────────────────────────

echo "→ A construir lambda.zip..."
LAMBDA_TMP="$BUILD/lambda_tmp"
mkdir -p "$LAMBDA_TMP"
cp "$ROOT/src/normal python/main.py" "$LAMBDA_TMP/"
cd "$LAMBDA_TMP" && zip -r "$BUILD/lambda.zip" main.py && cd "$ROOT"
rm -rf "$LAMBDA_TMP"
echo "   ✓ build/lambda.zip criado"

# ── 3. Upload para S3 ────────────────────────────────────────────────────────
# O Terraform vai ler estes ficheiros via data source (sem paths locais).

echo "→ A fazer upload para s3://$BUCKET_NAME ..."
aws s3 cp "$BUILD/utils_layer.zip" "s3://$BUCKET_NAME/layers/utils_layer.zip"
echo "   ✓ layers/utils_layer.zip"

aws s3 cp "$BUILD/lambda.zip" "s3://$BUCKET_NAME/functions/lambda.zip"
echo "   ✓ functions/lambda.zip"

echo ""
echo "Build e upload concluídos."
