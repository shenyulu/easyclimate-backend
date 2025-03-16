export CC=gcc
export FC=ifx
find . -type d -name "__pycache__" -exec rm -rf {} +
# https://github.com/mesonbuild/meson-python/issues/507
python -m build --wheel --no-isolation
