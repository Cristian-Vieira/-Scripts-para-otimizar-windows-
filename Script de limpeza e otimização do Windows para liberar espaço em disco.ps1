<#
.SYNOPSIS
    Script de limpeza e otimização do Windows para liberar espaço em disco e melhorar o desempenho.

.DESCRIPTION
    Remove arquivos temporários, caches, relatórios de erro e esvazia a lixeira.
    O script requer execução com privilégios de administrador para acesso completo ao sistema.

.VERSION
    2.2

.AUTHOR
    Cristian Vieira (Revisado por Manus)
#>

#region Configuração Inicial
$ErrorActionPreference = "SilentlyContinue"
Set-StrictMode -Version Latest

# Validação de privilégios de Administrador
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
    Write-Warning "Este script precisa ser executado como Administrador."
    Write-Host "Execute o PowerShell como Administrador e tente novamente." -ForegroundColor Yellow
    if ($Host.Name -eq "ConsoleHost") { pause }
    exit 1
}

# Exibir cabeçalho
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host "       Script de Limpeza do Windows v2.2" -ForegroundColor Yellow
Write-Host "==============================================" -ForegroundColor Cyan
#endregion

#region Funções Auxiliares
# Função otimizada para limpar pastas de forma segura
function Clear-Folder {
    param(
        [string]$Path,
        [string]$Description = $Path
    )
    
    if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
        Write-Host "ℹ Pasta não encontrada ou inválida: $Description" -ForegroundColor Gray
        return
    }

    Write-Host "⏳ Limpando: $Description" -ForegroundColor Gray
    try {
        # Usar -PipelineVariable para processamento mais limpo e obter contagem
        $items = Get-ChildItem -LiteralPath $Path -Force -Recurse
        if ($items) {
            $items | Remove-Item -Force -Recurse -ErrorAction Stop
            Write-Host "✔ Limpeza realizada em: $Description" -ForegroundColor Green
        } else {
            Write-Host "✔ Pasta já estava vazia: $Description" -ForegroundColor Green
        }
    }
    catch {
        Write-Warning "Não foi possível limpar completamente '$Description'. Alguns arquivos podem estar em uso. Erro: $($_.Exception.Message)"
    }
}

# Função para executar um comando com tratamento de erro
function Invoke-SafeCommand {
    param(
        [scriptblock]$Command,
        [string]$SuccessMessage,
        [string]$ErrorMessage
    )
    
    try {
        & $Command
        if ($LASTEXITCODE -ne 0 -and $LASTEXITCODE -ne $null) {
            throw "Comando externo falhou com código de saída: $LASTEXITCODE"
        }
        Write-Host "✔ $SuccessMessage" -ForegroundColor Green
    }
    catch {
        Write-Warning "$ErrorMessage. Erro: $($_.Exception.Message)"
    }
}
#endregion

#region Execução da Limpeza
$startTime = Get-Date
Write-Host "Início da limpeza: $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')" -ForegroundColor Gray
Write-Host ""

# 1. Limpeza de Pastas Temporárias
Clear-Folder -Path $env:TEMP -Description "Temp do usuário ($env:TEMP)"
Clear-Folder -Path "C:\Windows\Temp" -Description "Temp do Windows (C:\Windows\Temp)"

# 2. Limpeza do Cache do Windows Update
Write-Host "⏳ Gerenciando serviço do Windows Update..." -ForegroundColor Gray
$wuService = Get-Service -Name wuauserv -ErrorAction SilentlyContinue
if ($wuService.Status -eq 'Running') {
    Stop-Service -Name wuauserv -Force
}
Clear-Folder -Path "C:\Windows\SoftwareDistribution\Download" -Description "Cache do Windows Update"
if ($wuService.Status -ne 'Running') {
    Start-Service -Name wuauserv
}
Write-Host "✔ Serviço do Windows Update restaurado." -ForegroundColor Green


# 3. Limpeza de Caches do Sistema e Usuário
Write-Host "⏳ Limpando caches diversos..." -ForegroundColor Gray
# Cache de Miniaturas (Thumbnails)
$thumbPath = "$env:LOCALAPPDATA\Microsoft\Windows\Explorer"
Get-ChildItem -Path $thumbPath -Filter "thumbcache_*.db" -Force | Remove-Item -Force
# Cache de Ícones
Invoke-SafeCommand -Command { ie4uinit.exe -ClearIconCache } -SuccessMessage "Cache de ícones limpo." -ErrorMessage "Falha ao limpar cache de ícones"

# 4. Limpeza de Relatórios de Erro do Windows (WER)
Clear-Folder -Path "$env:ProgramData\Microsoft\Windows\WER\ReportQueue" -Description "Fila de Relatórios de Erro"
Clear-Folder -Path "$env:ProgramData\Microsoft\Windows\WER\ReportArchive" -Description "Arquivo de Relatórios de Erro"

# 5. Esvaziar Lixeira
Write-Host "⏳ Esvaziando Lixeira..." -ForegroundColor Gray
try {
    Clear-RecycleBin -Force -ErrorAction Stop
    Write-Host "✔ Lixeira esvaziada." -ForegroundColor Green
}
catch {
    Write-Warning "Não foi possível esvaziar a lixeira. Erro: $($_.Exception.Message)"
}

# 6. Limpeza de Caches de Rede
Invoke-SafeCommand -Command { ipconfig /flushdns } -SuccessMessage "Cache DNS limpo." -ErrorMessage "Falha ao limpar cache DNS"

# 7. Otimização de Disco (Desfragmentação/TRIM)
Write-Host "⏳ Verificando tipo de disco para otimização..." -ForegroundColor Gray
$mainDrive = Get-PhysicalDisk | Where-Object { $_.DeviceID -match "0" }
if ($mainDrive.MediaType -eq 'SSD') {
    Write-Host "ℹ Otimizando SSD (TRIM)..." -ForegroundColor Gray
    Optimize-Volume -DriveLetter C -ReTrim -Verbose
} else {
    Write-Host "ℹ Otimizando HDD (Desfragmentação)..." -ForegroundColor Gray
    Optimize-Volume -DriveLetter C -Defrag -Verbose
}

# 8. Limpeza de Logs de Eventos do Windows
Write-Host "⏳ Limpando logs de eventos..." -ForegroundColor Gray
Get-WinEvent -ListLog * | ForEach-Object {
    $logName = $_.LogName
    wevtutil.exe clear-log $logName 2>$null
}
Write-Host "✔ Logs de eventos limpos." -ForegroundColor Green

#endregion

#region Finalização
$endTime = Get-Date
$duration = New-TimeSpan -Start $startTime -End $endTime

Write-Host ""
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host "Limpeza concluída em $($duration.ToString('mm\:ss'))!" -ForegroundColor Green
Write-Host "Finalizado em: $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')" -ForegroundColor Gray
Write-Host "==============================================" -ForegroundColor Cyan

Write-Host ""
Write-Host "💡 Dica: Para garantir que todas as otimizações tenham efeito, recomenda-se reinicializar o sistema." -ForegroundColor Magenta

if ($Host.Name -eq "ConsoleHost") { pause }
#endregion
