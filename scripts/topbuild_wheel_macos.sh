#!/bin/bash

set -euo pipefail

# macOS 没有 manylinux 这种统一运行时标准。
# 这里采用“多 Python 版本 + 固定 deployment target + 当前架构 wheel”的方式，
# 尽可能扩大兼容范围。

PYTHON_CANDIDATES=(
  "python3.10"
  "python3.11"
  "python3.12"
  "python3.13"
  "python3.14"
)

MACOSX_DEPLOYMENT_TARGET="${MACOSX_DEPLOYMENT_TARGET:-12.0}"
ARCHFLAGS="${ARCHFLAGS:-}"

mkdir -p ./dist

echo "[INFO] MACOSX_DEPLOYMENT_TARGET=${MACOSX_DEPLOYMENT_TARGET}"
if [ -n "${ARCHFLAGS}" ]; then
  echo "[INFO] ARCHFLAGS=${ARCHFLAGS}"
fi

for pybin in "${PYTHON_CANDIDATES[@]}"; do
  if ! command -v "${pybin}" >/dev/null 2>&1; then
    echo "[WARN] skip ${pybin}: not found"
    continue
  fi

  echo "[INFO] Process ${pybin}"
  echo "------------------------------------"

  "${pybin}" -m pip install -r ./requirement.txt

  MACOSX_DEPLOYMENT_TARGET="${MACOSX_DEPLOYMENT_TARGET}" \
  ARCHFLAGS="${ARCHFLAGS}" \
  PYTHON_BIN="${pybin}" \
  bash ./scripts/build_wheel_macos.sh

  echo "[INFO] END Process ${pybin}"
  echo "----------------------------------------"
done
