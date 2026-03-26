#!/bin/bash

set -euo pipefail

PYTHON_BIN="${PYTHON_BIN:-python}"

export CC="${CC:-clang}"
export FC="${FC:-gfortran}"
export CXX="${CXX:-clang++}"
export MACOSX_DEPLOYMENT_TARGET="${MACOSX_DEPLOYMENT_TARGET:-11.0}"

find . -type d -name "__pycache__" -exec rm -rf {} +

# Certain Fortran sources require additional compatibility parameters under gfortran/macOS.
export FFLAGS="${FFLAGS:--O2 -fPIC}"
export FCFLAGS="${FCFLAGS:-${FFLAGS}}"

"${PYTHON_BIN}" -m build --wheel --no-isolation
