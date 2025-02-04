﻿$ErrorActionPreference = 'Stop'

$toolsDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

# *** Automatically filled ***
$packageName  = 'sabnzbd'
$packageArgs  = @{
    packageName    = $packageName
    fileType       = 'exe'
    url            = 'https://github.com/sabnzbd/sabnzbd/releases/download/2.3.6Beta1/SABnzbd-2.3.6Beta1-win-setup.exe'
    silentArgs     = '/S'
    checksum       = '4b87434a1daaba3fc4e1e14be5c566c8bbc20818c8e3e5ad6e2e4cef9befacda'
    checksumType   = 'sha256'
    validExitCodes = @(0)
}
$softwareName = 'SABnzbd*'
# *** Automatically filled ***

Install-ChocolateyPackage @packageArgs

. "$toolsDir\Get-InstallPath.ps1"
$installPath = Get-InstallPath $packageName $softwareName

if ($installPath) {
    Push-Location $installPath
    try {
        Write-Host 'Installing services...'

        $helper = 'SABnzbd-helper.exe'
        if (Test-Path $helper) {
            & ".\$helper" install
            Set-Service 'SABhelper' -StartupType Automatic
        }

        $service = 'SABnzbd-service.exe'
        if (Test-Path $service) {
            $iniPath = Join-Path $Env:LOCALAPPDATA 'sabnzbd\sabnzbd.ini'
            & ".\$service" -f $iniPath install
            Set-Service 'SABnzbd' -StartupType Automatic
        }
    } finally {
        Pop-Location
    }
}

Write-Host 'Starting services...'
Start-Service '*' -Include 'SABnzbd', 'SABhelper'
