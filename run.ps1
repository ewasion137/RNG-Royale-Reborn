$love = "C:\Program Files\LOVE\love.exe"
if (-not (Test-Path $love)) {
    Write-Error "Love2D not found at $love"
    exit 1
}
& $love $PSScriptRoot
