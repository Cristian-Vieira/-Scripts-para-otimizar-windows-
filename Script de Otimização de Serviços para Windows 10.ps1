# Script de Otimização de Serviços para Windows 10 Pro Gamer

$services = @(
    "DiagTrack",              # Telemetria
    "WMPNetworkSvc",          # Compartilhamento de Mídia
    "XblAuthManager",         # Xbox Live Auth Manager
    "XblGameSave",            # Xbox Live Game Save
    "XboxNetApiSvc",          # Xbox Live Networking
    "Fax",                    # Fax
    "MapsBroker",             # Download de mapas offline
    "PrintNotify",            # Notificação de Impressora
    "Spooler",                # Impressão (desative se não usa impressora)
    "WerSvc",                 # Relatórios de Erro do Windows
    "TrkWks",                 # Rastreador de Links Distribuídos
    "RemoteRegistry",         # Registro Remoto
    "RetailDemo",             # Modo Demo
    "SharedAccess",           # Compartilhamento de Conexão de Internet
    "SysMain"                 # Superfetch (ajuda em HDDs, mas ocupa RAM em SSD)
)

foreach ($service in $services) {
    Get-Service -Name $service -ErrorAction SilentlyContinue | Set-Service -StartupType Disabled
    Write-Host "$service desativado."
}

Write-Host "Otimização concluída. Reinicie para aplicar completamente."
