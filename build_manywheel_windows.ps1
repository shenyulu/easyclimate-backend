# git clone https://github.com/pyenv-win/pyenv-win.git

$Env:PYENV=".\pyenv-win\pyenv-win"
$Env:PYENV_ROOT=".\pyenv-win\pyenv-win"
$Env:PYENV_HOME=".\pyenv-win\pyenv-win"

$currentPath = [System.Environment]::GetEnvironmentVariable('PATH', [System.EnvironmentVariableTarget]::Process)
$newPath = "$Env:PYENV_HOME\bin;$Env:PYENV_HOME\shims;$currentPath"
[System.Environment]::SetEnvironmentVariable('PATH', $newPath, [System.EnvironmentVariableTarget]::Process)

# pyenv install 3.13.1
# pyenv install 3.12.8
# pyenv install 3.11.9
# pyenv install 3.10.11
# pyenv install 3.9.13

pyenv global 3.12.8
pip install -r build_requirement_windows.txt
.\build_wheel_windows.ps1