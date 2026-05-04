# Check Intel Fortran Compiler status
Write-Host "🔍 Checking Intel Fortran Compiler..." -ForegroundColor Cyan
ifx /QV

$pythonVersions = @("3.10", "3.11", "3.12", "3.13", "3.14")

# 自动获取系统临时目录
$venvBasePath = Join-Path $env:TEMP "easyclimate-venvs"
New-Item -ItemType Directory -Force -Path $venvBasePath | Out-Null

Write-Host "📁 Virtual environments will be created in: $venvBasePath" -ForegroundColor Yellow
Write-Host ""

foreach ($version in $pythonVersions) {
    Write-Host "🐍 Building wheel for Python $version..." -ForegroundColor Green
    
    # 在临时目录创建虚拟环境
    $venvPath = Join-Path $venvBasePath ".venv-$version"
    Write-Host "   ⚙️  Creating virtual environment..." -ForegroundColor Gray
    uv venv $venvPath --python $version --seed
    
    # 激活虚拟环境
    Write-Host "   ✅ Activating virtual environment..." -ForegroundColor Gray
    & "$venvPath\Scripts\Activate.ps1"

    # 根据 Python 版本选择不同的 requirements 文件
    if ($version -eq "3.14") {
        $requirementFile = ".\scripts\build_requirement_3_14_windows.txt"
        Write-Host "   📦 Installing dependencies from: $requirementFile (Python 3.14 specific)" -ForegroundColor Magenta
    } else {
        $requirementFile = ".\scripts\build_requirement_windows.txt"
        Write-Host "   📦 Installing dependencies from: $requirementFile" -ForegroundColor Gray
    }
    
    uv pip install -r $requirementFile
    
    # 调用单版本构建脚本
    Write-Host "   🔨 Building wheel..." -ForegroundColor Gray
    & .\scripts\build_wheel_windows.ps1
    
    # 停用虚拟环境
    deactivate
    
    # 删除该版本的虚拟环境
    Write-Host "   🧹 Cleaning up virtual environment for Python $version..." -ForegroundColor Gray
    Remove-Item -Path $venvPath -Recurse -Force -ErrorAction SilentlyContinue
    
    Write-Host "   ✨ Completed wheel for Python $version" -ForegroundColor Green
    Write-Host "   ----------------------------------------" -ForegroundColor DarkGray
    Write-Host ""
}

# 清理整个虚拟环境基础目录
Write-Host "🧹 Cleaning up all virtual environments..." -ForegroundColor Yellow
Remove-Item -Path $venvBasePath -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "🎉 All builds completed and cleaned up successfully!" -ForegroundColor Green
