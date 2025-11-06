@echo off
:: ==============================
:: Script de otimização gamer
:: ==============================


echo [1/10] Desativando serviços desnecessários...
sc config DiagTrack start= disabled
sc config dmwappushservice start= disabled
sc config Spooler start= disabled
sc config Fax start= disabled
sc config WerSvc start= disabled
sc config wisvc start= disabled
sc config WMPNetworkSvc start= disabled
sc config RemoteRegistry start= disabled
sc config HomeGroupListener start= disabled
sc config HomeGroupProvider start= disabled
sc config XblAuthManager start= disabled
sc config XblGameSave start= disabled
sc config XboxNetApiSvc start= disabled
sc config RemoteAccess start= disabled
sc config SessionEnv start= disabled

echo [2/10] Desativando telemetria e Cortana...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v AllowCortana /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v DisableWebSearch /t REG_DWORD /d 1 /f

echo [3/10] Desativando Windows Copilot...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" /v TurnOffWindowsCopilot /t REG_DWORD /d 1 /f

echo [4/10] Desativando GameDVR...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v AllowGameDVR /t REG_DWORD /d 0 /f

echo [5/10] Desativando recursos de nuvem e sugestões...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v DisableWindowsConsumerFeatures /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v DisableSoftLanding /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v DisableThirdPartySuggestions /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v DisableWindowsSpotlightFeatures /t REG_DWORD /d 1 /f

echo [6/10] Otimizando perfil de jogos e performance...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v ClearPageFileAtShutdown /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v NetworkThrottlingIndex /t REG_DWORD /d 4294967295 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v SystemResponsiveness /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v Win32PrioritySeparation /t REG_DWORD /d 38 /f
powercfg -setactive SCHEME_MAX

echo [7/10] Desativando hibernação (se não tiver sido feita ainda)...
powercfg -h off

echo [8/10] Ajustes para usuário atual (HKCU)...
reg add "HKCU\Software\Microsoft\Windows\Shell\Copilot" /v TurnOffCopilot /t REG_DWORD /d 1 /f
reg add "HKCU\System\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d 0 /f
reg add "HKCU\SOFTWARE\Microsoft\GameBar" /v ShowStartupPanel /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SystemPaneSuggestionsEnabled /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SilentInstalledAppsEnabled /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SoftLandingEnabled /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-338388Enabled /t REG_DWORD /d 0 /f

echo [9/10] Removendo apps desnecessários do usuário atual...
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "Get-AppxPackage *xbox*,*onedrive*,*skype*,*Teams*,*solitaire*,*bing*,*zune*,*getstarted*,*office*,*YourPhone*,*PowerAutomateDesktop* | Remove-AppxPackage"

echo [10/10] Removendo apps provisionados para novos usuários...
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -match 'xbox|skype|Teams|solitaire|bing|zune|getstarted|office|YourPhone|PowerAutomateDesktop' } | ForEach-Object { Remove-AppxProvisionedPackage -Online -PackageName $_.PackageName }"

echo =======================================
echo Script finalizado! Reinicie o computador
echo =======================================
pause
