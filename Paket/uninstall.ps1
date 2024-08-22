# Intune_Run-Enable-Sandbox - uninstall.ps1
# Version 1.0
# Date: 22.08.2024
# Author: Jonas Techand
# Description: Disable the Windows Sandbox Enviroment using PowerShell.
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

# Start-Transcript -Path "$env:TEMP\IntunePackage\$PackageName\Uninstall.log" -NoClobber -Append
Start-Transcript -Path "C:\source\IntunePackage\$PackageName\Uninstall.log" -NoClobber -Append

# Check if Sandbox is enabled
$SandboxEnabled = Get-WindowsOptionalFeature -FeatureName "Containers-DisposableClientVM" -Online | Select-Object -Property State
if (-not $SandboxEnabled) {
    Write-Host "-> Sandbox is not enabled. Skipping disabling."
    Stop-Transcript
    exit 0
} else {
    Write-Host "-> Disabling Sandbox..."
    Disable-WindowsOptionalFeature -FeatureName "Containers-DisposableClientVM" -Online #Disable the Sandbox Feature. this requiers a restart.
    shutdown -r -t 60 -c "Restarting to disable Sandbox feature" #Restart the computer to disable the Sandbox feature
    if ($SandboxEnabled) {
        Write-Host "-> Sandbox could not be disabled. Exiting"
        Stop-Transcript
        exit 1
    } else {
        Write-Host "-> Sandbox disabled successfully."
        Stop-Transcript
        exit 0
    }
}