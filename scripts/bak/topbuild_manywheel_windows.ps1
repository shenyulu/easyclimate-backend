# Check Intel Fortran Compiler status
# 检查 Intel Fortran 编译器状态
ifx /QV

# python interpreter register directory
# python解释器暂存目录
$targetPath = (Join-Path $env:TEMP "tmp_ecl")

# Basic parameters
# 基本参数
$localpath = (Get-Location).Path
${repository_python_build_requirement} = Join-Path $localpath 'scripts' 'build_requirement_windows.txt'
$deploy_win = 'deploy_win'

# Remove target directory if it exists
# 如果目标目录存在则删除
if (Test-Path $targetPath) {
    Remove-Item -Path $targetPath -Recurse -Force
}

# Extract file
# 解压文件
Expand-Archive -Path (Join-Path $localpath $deploy_win 'pyenv-win.zip') -DestinationPath $targetPath

# pyenv-win basic parameters
# pyenv-win基本参数
$Env:PYENV = Join-Path $targetPath 'pyenv-win' 'pyenv-win'
$Env:PATH += ";" + (Join-Path $Env:PYENV "bin") + ";" + (Join-Path $Env:PYENV "shims")
# Set up mirror
# 设置镜像
$env:PYTHON_BUILD_MIRROR_URL="https://mirrors.huaweicloud.com/python/"
pyenv update

# Install python
# 安装python
pyenv install 3.10.11
pyenv install 3.11.9
pyenv install 3.12.9
pyenv install 3.13.2
# pyenv install 3.14.0a5

# Install dependencies and create virtual environments
# 安装依赖，创建虚拟环境
$pythonPath_310 = Join-Path  $Env:PYENV  "versions" "3.10.11" "python.exe"
& $pythonPath_310 -m pip install virtualenv
$targetenvPath = (Join-Path $targetPath venv_py310)
& $pythonPath_310 -m virtualenv $targetenvPath
'& ' + (Join-Path $targetenvPath "Scripts" "activate.ps1") | Out-File -FilePath (Join-Path $localpath $deploy_win "activate_py310env.ps1")

$pythonPath_311 = Join-Path  $Env:PYENV  "versions" "3.11.9" "python.exe"
& $pythonPath_311 -m pip install virtualenv
$targetenvPath = (Join-Path $targetPath venv_py311)
& $pythonPath_311 -m virtualenv $targetenvPath
'& ' + (Join-Path $targetenvPath "Scripts" "activate.ps1") | Out-File -FilePath (Join-Path $localpath $deploy_win "activate_py311env.ps1")

$pythonPath_312 = Join-Path  $Env:PYENV  "versions" "3.12.9" "python.exe"
& $pythonPath_312 -m pip install virtualenv
$targetenvPath = (Join-Path $targetPath venv_py312)
& $pythonPath_312 -m virtualenv $targetenvPath
'& ' + (Join-Path $targetenvPath "Scripts" "activate.ps1") | Out-File -FilePath (Join-Path $localpath $deploy_win "activate_py312env.ps1")

$pythonPath_313 = Join-Path  $Env:PYENV  "versions" "3.13.2" "python.exe"
& $pythonPath_313 -m pip install virtualenv
$targetenvPath = (Join-Path $targetPath venv_py313)
& $pythonPath_313 -m virtualenv $targetenvPath
'& ' + (Join-Path $targetenvPath "Scripts" "activate.ps1") | Out-File -FilePath (Join-Path $localpath $deploy_win "activate_py313env.ps1")

# $pythonPath_314 = Join-Path  $Env:PYENV  "versions" "3.14.0a5" "python.exe"
# & $pythonPath_314 -m pip install virtualenv
# $targetenvPath = (Join-Path $targetPath venv_py314)
# & $pythonPath_314 -m virtualenv $targetenvPath
# '& ' + (Join-Path $targetenvPath "Scripts" "activate.ps1") | Out-File -FilePath (Join-Path $localpath $deploy_win "activate_py314env.ps1")

# Compile
# 编译
& (Join-Path '.\'$deploy_win "activate_py310env.ps1") && & python -m pip install -r ${repository_python_build_requirement} && & .\scripts\build_wheel_windows.ps1
& (Join-Path '.\'$deploy_win "activate_py311env.ps1") && & python -m pip install -r ${repository_python_build_requirement} && & .\scripts\build_wheel_windows.ps1
& (Join-Path '.\'$deploy_win "activate_py312env.ps1") && & python -m pip install -r ${repository_python_build_requirement} && & .\scripts\build_wheel_windows.ps1
& (Join-Path '.\'$deploy_win "activate_py313env.ps1") && & python -m pip install -r ${repository_python_build_requirement} && & .\scripts\build_wheel_windows.ps1
# & (Join-Path '.\'$deploy_win "activate_py314env.ps1") && & python -m pip install -r ${repository_python_build_requirement} && & .\scripts\build_wheel_windows.ps1

# Delete files to Recycle bin
# 删除文件至回收站
# https://stackoverflow.com/questions/502002/how-do-i-move-a-file-to-the-recycle-bin-using-powershell
deactivate
Write-Output "正在清理文件至回收站... （你可以在回收站中彻底删除临时文件）"
Write-Output "Cleaning up files to the Recycle Bin... (Tips: You can delete temporary files completely in the Recycle Bin)"
Add-Type -AssemblyName Microsoft.VisualBasic
[Microsoft.VisualBasic.FileIO.FileSystem]::DeleteDirectory($targetPath,'OnlyErrorDialogs','SendToRecycleBin')
Add-Type -AssemblyName Microsoft.VisualBasic
[Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile((Join-Path $localpath $deploy_win "activate_py310env.ps1"),'OnlyErrorDialogs','SendToRecycleBin')
Add-Type -AssemblyName Microsoft.VisualBasic
[Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile((Join-Path $localpath $deploy_win "activate_py311env.ps1"),'OnlyErrorDialogs','SendToRecycleBin')
Add-Type -AssemblyName Microsoft.VisualBasic
[Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile((Join-Path $localpath $deploy_win "activate_py312env.ps1"),'OnlyErrorDialogs','SendToRecycleBin')
Add-Type -AssemblyName Microsoft.VisualBasic
[Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile((Join-Path $localpath $deploy_win "activate_py313env.ps1"),'OnlyErrorDialogs','SendToRecycleBin')
Add-Type -AssemblyName Microsoft.VisualBasic
[Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile((Join-Path $localpath $deploy_win "activate_py314env.ps1"),'OnlyErrorDialogs','SendToRecycleBin')
