# Check Intel Fortran Compiler status
ifx /QV

# https://mesonbuild.com/meson-python/how-to-guides/sdist.html
python -m build --no-isolation --sdist .