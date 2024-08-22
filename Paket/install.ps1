# Intune_Run-Enable-Sandbox - install.ps1
# Version 1.0
# Date: 22.08.2024
# Author: Jonas Techand
# Description: Enable the Windows Sandbox Enviroment using PowerShell.
# --------------------------------------------------------------------------
# ChangeLog: Script creation
# --------------------------------------------------------------------------
# Dependencies: NONE
# --------------------------------------------------------------------------
$PackageName = "Intune_Enable-Sandbox"

# Check for running as admin
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$adminRole = [Security.Principal.WindowsBuiltInRole]::Administrator

if (-not $currentPrincipal.IsInRole($adminRole)) {
    Write-Host "Restarting script with administrative privileges..."
    Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$PSCommandPath`"" -Verb RunAs
    Start-Sleep 120
    exit
}

write-warning "The script has been started with administrative privileges."

# Start-Transcript -Path "$env:TEMP\IntunePackage\$PackageName\Install.log" -NoClobber -Append
Start-Transcript -Path "C:\source\IntunePackage\$PackageName\Install.log" -NoClobber -Append

# Check if Sandbox is enabled
$SandboxEnabled = Get-WindowsOptionalFeature -FeatureName "Containers-DisposableClientVM" -Online | Select-Object -Property State
if ($SandboxEnabled) {
    Write-Host "-> Enabling Sandbox..."
    Enable-WindowsOptionalFeature -FeatureName "Containers-DisposableClientVM" -All -Online #Enable the Sandbox Feature. this requiers a restart.
    shutdown -r -t 60 -c "Restarting to enable Sandbox feature" #Restart the computer to enable the Sandbox feature
    if (-not $SandboxEnabled) {
        Write-Host "-> Sandbox could not be enabled. Exiting."
        Stop-Transcript
        exit 1
    } else {
        Write-Host "-> Sandbox enabled successfully."
        Stop-Transcript
        exit 0
    }
} else {
    Write-Host "-> Sandbox is already enabled. Skipping enabling."
    Stop-Transcript
    exit 0
}

$SandboxEnabled = Get-WindowsOptionalFeature -FeatureName "Containers-DisposableClientVM" -Online | Select-Object -Property State
if ("State" -eq $SandboxEnabled) {
    Write-Host "1"
} else {
    Write-Host "2"
}