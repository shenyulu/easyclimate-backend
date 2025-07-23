# Check Intel Fortran Compiler status
# 检查 Intel Fortran 编译器状态
ifx /QV

# python interpreter register directory
# python解释器暂存目录
$targetPath = (Join-Path $env:TEMP "tmp_ecl")

# Basic parameters
# 基本参数
$localpath = (Get-Location).Path
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

pyenv install -l

Write-Output "正在清理文件至回收站... （你可以在回收站中彻底删除临时文件）"
Write-Output "Cleaning up files to the Recycle Bin... (Tips: You can delete temporary files completely in the Recycle Bin)"
Add-Type -AssemblyName Microsoft.VisualBasic
[Microsoft.VisualBasic.FileIO.FileSystem]::DeleteDirectory($targetPath,'OnlyErrorDialogs','SendToRecycleBin')
