# Check Intel Fortran Compiler status
ifx /QV

$Env:CC="cl"
$Env:FC="ifx"

# https://mesonbuild.com/meson-python/how-to-guides/sdist.html
python -m build --no-isolation --sdist .