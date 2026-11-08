# Chạy hệ thống BTH9 trên Windows (Docker Desktop + .NET 8 SDK).
# Không đụng dữ liệu git bẩn. Không thanh toán tiền thật.
$ErrorActionPreference = "Stop"
$root = Resolve-Path (Join-Path $PSScriptRoot "..\..")
Set-Location $root

Write-Host "Kiem tra docker..."
docker version | Out-Host
docker compose version | Out-Host
dotnet --version | Out-Host

Write-Host "Build va khoi dong Compose (lan dau co the mat nhieu phut)..."
docker compose up -d --build

Write-Host "Cho Eureka va gateway san sang..."
$ready = $false
for ($i = 0; $i -lt 40; $i++) {
    try {
        $code = (Invoke-WebRequest -UseBasicParsing http://localhost:8099/ -TimeoutSec 3).StatusCode
        if ($code -ge 200) { $ready = $true; break }
    } catch {}
    Start-Sleep -Seconds 5
}
if (-not $ready) {
    Write-Warning "Gateway chua tra loi. Xem: docker compose ps ; docker compose logs --tail 80"
    exit 1
}

Write-Host ""
Write-Host "UI:      http://localhost:5081"
Write-Host "Gateway: http://localhost:8099"
Write-Host "Eureka:  http://localhost:8761"
Write-Host "Dang nhap: jimmy.solid / secret"
Write-Host "Smoke API: bash scripts/bth9-smoke.sh   (hoac Git Bash / WSL)"
