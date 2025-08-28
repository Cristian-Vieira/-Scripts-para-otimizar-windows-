@echo off
color 0A
title Otimizando o sistema...
echo A otimizacao do sistema foi iniciada...
timeout /t 3 /nobreak >nul
cls

:: Desativa Biometria (Windows Hello)
reg add "HKLM\SOFTWARE\Policies\Microsoft\Biometrics" /v "Enabled" /t REG_DWORD /d "0" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Biometrics\Credential Provider" /v "Enabled" /t REG_DWORD /d "0" /f

:: Desativa Localização
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" /v "Value" /d "Deny" /f

:: Remove o OneDrive do Explorador
reg delete "HKEY_CLASSES_ROOT\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /f
reg delete "HKEY_CLASSES_ROOT\WOW6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /f

:: Desativa GameDVR / Game Bar
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v "AllowGameDVR" /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" /v "AppCaptureEnabled" /t REG_DWORD /d 0 /f

:: Desativa Telemetria (envio à Microsoft)
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f

:: Desativa SysMain (Superfetch)
sc stop sysmain
sc config sysmain start=disabled

:: Desativa Web Search no menu iniciar
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "DisableWebSearch" /t REG_DWORD /d 1 /f

:: Desativa Hibernação (e Inicialização Rápida)
powercfg.exe /hibernate off

:: Fim da otimização
cls
echo Otimizacoes aplicadas com sucesso!
pause
exit
