#!/bin/bash

set -euo pipefail

# 单文件试编译：先验证一个最小 Fortran/F2PY 扩展在 macOS + clang/gfortran 下可构建。
# 默认选择不依赖 MPI、也不依赖 Intel SVML 的模块，避免修改原始 Fortran 源码。

MODULE_NAME="${1:-redfit_x}"
PYTHON_BIN="${PYTHON_BIN:-python3}"
BUILD_ROOT="build-single-module"
COMMON_FC_FLAGS=(-O2 -fPIC)

export CC="${CC:-clang}"
export FC="${FC:-gfortran}"
export CXX="${CXX:-clang++}"

echo "[info] python = ${PYTHON_BIN}"
echo "[info] CC=${CC}"
echo "[info] FC=${FC}"
echo "[info] CXX=${CXX}"
echo "[info] module=${MODULE_NAME}"

find . -type d -name "__pycache__" -exec rm -rf {} +

case "${MODULE_NAME}" in
  redfit_x)
    TARGET_DIR="subprojects/redfit_x"
    PYF_FILE="_ecl_redfit_x.pyf"
    EXT_NAME="_ecl_redfit_x"
    FORTRAN_SOURCES=(
      "src/nrtype.f90"
      "src/nrutil.f90"
      "src/mutil.f90"
      "src/nr.f90"
      "src/ran.f90"
      "src/ran1.f"
      "src/sort.f90"
      "src/erfcc.f90"
      "src/gser.f90"
      "src/gcf.f90"
      "src/avevar.f90"
      "src/gammp.f90"
      "src/gammln.f90"
      "redfit_x.f90"
    )
    COMMON_FC_FLAGS+=( -fdec )
    ;;
  wet_bulb)
    TARGET_DIR="subprojects/wet_bulb"
    PYF_FILE="_wet_bulb_temperature.pyf"
    EXT_NAME="_wet_bulb_temperature"
    FORTRAN_SOURCES=(
      "wet_bulb_temperature.f90"
    )
    echo "[warn] ${MODULE_NAME} 在原 Meson 中依赖 Intel SVML；此单文件测试仅尝试 gfortran 直编，不引入 SVML。"
    ;;
  *)
    echo "[error] unsupported module: ${MODULE_NAME}"
    echo "[error] supported modules: redfit_x, wet_bulb"
    exit 1
    ;;
esac

if ! command -v "${CC}" >/dev/null 2>&1; then
  echo "[error] C compiler not found: ${CC}"
  exit 1
fi

if ! command -v "${FC}" >/dev/null 2>&1; then
  echo "[error] Fortran compiler not found: ${FC}"
  exit 1
fi

if ! command -v "${PYTHON_BIN}" >/dev/null 2>&1; then
  echo "[error] Python not found: ${PYTHON_BIN}"
  exit 1
fi

ABS_TARGET_DIR="$(pwd)/${TARGET_DIR}"
BUILD_DIR="$(pwd)/${BUILD_ROOT}/${MODULE_NAME}"

rm -rf "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}"

pushd "${ABS_TARGET_DIR}" >/dev/null

NUMPY_INCLUDE="$(${PYTHON_BIN} -c 'import numpy; print(numpy.get_include())')"
F2PY_INCLUDE="$(${PYTHON_BIN} -c 'import numpy.f2py; print(numpy.f2py.get_include())')"
PYTHON_INCLUDE="$(${PYTHON_BIN} -c 'from sysconfig import get_paths; print(get_paths()["include"])')"
PYTHON_LIBDIR="$(${PYTHON_BIN} -c 'import sysconfig; print(sysconfig.get_config_var("LIBDIR") or "")')"
PYTHON_LDLIBRARY="$(${PYTHON_BIN} -c 'import sysconfig; print(sysconfig.get_config_var("LDLIBRARY") or "")')"
PYTHON_DYLIB_NAME="$(${PYTHON_BIN} -c 'import pathlib, sysconfig; libdir = pathlib.Path(sysconfig.get_config_var("LIBDIR") or ""); cands = sorted(libdir.glob("libpython*.dylib")); print(cands[0].name if cands else "")')"

echo "[info] numpy include: ${NUMPY_INCLUDE}"
echo "[info] f2py include: ${F2PY_INCLUDE}"
echo "[info] python include: ${PYTHON_INCLUDE}"
echo "[info] python libdir: ${PYTHON_LIBDIR}"
echo "[info] python ldlibrary: ${PYTHON_LDLIBRARY}"
echo "[info] python dylib: ${PYTHON_DYLIB_NAME}"

echo "[info] generating wrapper sources from ${PYF_FILE}"
"${PYTHON_BIN}" -m numpy.f2py "${PYF_FILE}" --lower --build-dir "${BUILD_DIR}"

WRAPPER_C="${BUILD_DIR}/${EXT_NAME}module.c"
WRAPPER_F="${BUILD_DIR}/${EXT_NAME}-f2pywrappers.f"
FORTRANOBJECT_C="${F2PY_INCLUDE}/fortranobject.c"

if [ ! -f "${WRAPPER_C}" ]; then
  echo "[error] missing generated C wrapper: ${WRAPPER_C}"
  exit 1
fi

OBJECTS=()

for src in "${FORTRAN_SOURCES[@]}"; do
  base_name="$(basename "${src}")"
  obj_name="${base_name%.*}.o"
  obj_path="${BUILD_DIR}/${obj_name}"
  echo "[info] compiling Fortran: ${src} -> ${obj_path}"
  "${FC}" "${COMMON_FC_FLAGS[@]}" -c "${src}" -J "${BUILD_DIR}" -I "${BUILD_DIR}" -o "${obj_path}"
  OBJECTS+=("${obj_path}")
done

if [ -f "${WRAPPER_F}" ]; then
  wrapper_obj="${BUILD_DIR}/$(basename "${WRAPPER_F}" .f).o"
  echo "[info] compiling F2PY Fortran wrapper: ${WRAPPER_F} -> ${wrapper_obj}"
  "${FC}" "${COMMON_FC_FLAGS[@]}" -c "${WRAPPER_F}" -J "${BUILD_DIR}" -I "${BUILD_DIR}" -o "${wrapper_obj}"
  OBJECTS+=("${wrapper_obj}")
fi

echo "[info] building extension via numpy.f2py"
EXT_SUFFIX="$(${PYTHON_BIN} -c 'import sysconfig; print(sysconfig.get_config_var("EXT_SUFFIX") or ".so")')"
OUTPUT_LIB="${BUILD_DIR}/${EXT_NAME}${EXT_SUFFIX}"
PYTHON_LINK_ARGS=()

if [ -n "${PYTHON_LIBDIR}" ] && [ -n "${PYTHON_LDLIBRARY}" ]; then
  PYTHON_LINK_ARGS+=("-L${PYTHON_LIBDIR}")
  if [ -n "${PYTHON_DYLIB_NAME}" ]; then
    python_link_name="${PYTHON_DYLIB_NAME#lib}"
    python_link_name="${python_link_name%.dylib}"
    PYTHON_LINK_ARGS+=("-l${python_link_name}")
  elif [[ "${PYTHON_LDLIBRARY}" == lib*.dylib ]]; then
    python_link_name="${PYTHON_LDLIBRARY#lib}"
    python_link_name="${python_link_name%.dylib}"
    PYTHON_LINK_ARGS+=("-l${python_link_name}")
  elif [[ "${PYTHON_LDLIBRARY}" == lib*.a ]]; then
    PYTHON_LINK_ARGS+=("${PYTHON_LIBDIR}/${PYTHON_LDLIBRARY}")
  fi
fi

echo "[info] linking extension with ${CC} -> ${OUTPUT_LIB}"
"${CC}" -shared \
  -o "${OUTPUT_LIB}" \
  "${WRAPPER_C}" \
  "${FORTRANOBJECT_C}" \
  "${OBJECTS[@]}" \
  -I"${PYTHON_INCLUDE}" \
  -I"${NUMPY_INCLUDE}" \
  -I"${F2PY_INCLUDE}" \
  -I"${BUILD_DIR}" \
  "${PYTHON_LINK_ARGS[@]}" \
  -L"$(dirname "$(${FC} -print-file-name=libgfortran.dylib)")" \
  -lgfortran -lquadmath -lm

echo "[info] build completed for ${EXT_NAME}"
echo "[info] output files:"
find "${BUILD_DIR}" -maxdepth 3 -type f | sed 's#^#  - #' | sort

popd >/dev/null
