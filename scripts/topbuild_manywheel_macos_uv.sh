#!/bin/bash

set -euo pipefail

# Here, the approach of "multiple Python versions + uv virtual 
# environment + fixed deployment target + current architecture 
# wheel" is adopted to maximize compatibility.

PYTHON_VERSIONS=(
  "3.10"
  "3.11"
  "3.12"
  "3.13"
  "3.14"
)

MACOSX_DEPLOYMENT_TARGET="${MACOSX_DEPLOYMENT_TARGET:-11.0}"
ARCHFLAGS="${ARCHFLAGS:-}"
UV_BIN="${UV_BIN:-uv}"
VENV_BASE_PATH="${TMPDIR:-/tmp}easyclimate-venvs"

mkdir -p ./dist
mkdir -p "${VENV_BASE_PATH}"

cleanup() {
  if [ -d "${VENV_BASE_PATH}" ]; then
    echo "[INFO] Cleaning up virtual environments in ${VENV_BASE_PATH}"
    rm -rf "${VENV_BASE_PATH}"
  fi
}

trap cleanup EXIT

echo "[INFO] MACOSX_DEPLOYMENT_TARGET=${MACOSX_DEPLOYMENT_TARGET}"
echo "[INFO] Virtual environments will be created in ${VENV_BASE_PATH}"
if [ -n "${ARCHFLAGS}" ]; then
  echo "[INFO] ARCHFLAGS=${ARCHFLAGS}"
fi

for version in "${PYTHON_VERSIONS[@]}"; do
  venv_path="${VENV_BASE_PATH}/.venv-${version}"
  requirement_file="./scripts/build_requirement_macos.txt"

  echo "[INFO] Building wheel for Python ${version}"
  echo "------------------------------------"

  if ! "${UV_BIN}" venv "${venv_path}" --python "${version}" --seed; then
    echo "[WARN] skip Python ${version}: uv failed to create virtual environment"
    echo "------------------------------------"
    continue
  fi

  # shellcheck disable=SC1090
  source "${venv_path}/bin/activate"

  echo "[INFO] Installing dependencies from ${requirement_file}"
  if ! "${UV_BIN}" pip install -r "${requirement_file}"; then
    echo "[WARN] dependency installation failed for Python ${version}"
    deactivate || true
    rm -rf "${venv_path}"
    echo "------------------------------------"
    continue
  fi

  echo "[INFO] Building wheel for Python ${version}"
  if ! MACOSX_DEPLOYMENT_TARGET="${MACOSX_DEPLOYMENT_TARGET}" \
    ARCHFLAGS="${ARCHFLAGS}" \
    PYTHON_BIN="python" \
    bash ./scripts/build_wheel_macos.sh; then
    echo "[WARN] build failed for Python ${version}"
    deactivate || true
    rm -rf "${venv_path}"
    echo "------------------------------------"
    continue
  fi

  deactivate

  rm -rf "${venv_path}"

  echo "[INFO] Completed wheel for Python ${version}"
  echo "----------------------------------------"
done
