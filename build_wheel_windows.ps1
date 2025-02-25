# git steidani/ConTrack
# ------------------------------
# $currentPath = Get-Location
# Set-Location $currentPath

# Remove-Item "$currentPath\easyclimate_backend\contrack" -Recurse -Force -ErrorAction SilentlyContinue -ErrorVariable err
# if ($err) {
#     Write-Host "Not find contrack folder, continue..."
# }
# New-Item -Path "$currentPath\tmp" -ItemType Directory
# git clone https://github.com/steidani/ConTrack.git "$currentPath\tmp"
# Copy-Item "$currentPath\tmp\contrack" "$currentPath\easyclimate_backend\contrack" -Recurse -Force
# Remove-Item "$currentPath\tmp" -Recurse -Force

# build wheel
# ------------------------------
$Env:CC="cl"
$Env:FC="ifx"
Get-ChildItem -Path . -Recurse -Directory -Filter __pycache__ | Remove-Item -Recurse -Force
# https://github.com/mesonbuild/meson-python/issues/507
python -m build --wheel --no-isolation
