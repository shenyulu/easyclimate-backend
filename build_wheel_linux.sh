export CC=icx # Not use `gcc` for link error
export FC=ifx
find . -type d -name "__pycache__" -exec rm -rf {} +
# https://github.com/mesonbuild/meson-python/issues/507
python -m build --wheel --no-isolation
