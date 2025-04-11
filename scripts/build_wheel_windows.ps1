$Env:CC="cl"
$Env:FC="ifx"
Get-ChildItem -Path . -Recurse -Directory -Filter __pycache__ | Remove-Item -Recurse -Force
# https://github.com/mesonbuild/meson-python/issues/507
python -m build --wheel --no-isolation
