# Remove-Item .\build -Recurse 

.\make.bat html
copy-item -path .\source\src\raw -destination .\build\html\src -recurse -force
