<#
Author: Ainsley Cabading
Script: os.ps1

Function: 
- Checks whether a client device has the latest Windows OS version to ensure a secure connection
to the company intranet

Result: osCheck [Success/Fail]
#>

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~GetBuildData Function~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Queries registry for device's current Build Number (22631, 22621 etc) and Update Build Revision [UBR] (3737)
# Example value should look like 22631.3737

function GetBuildData {
    $buildData = ""
    $registryQuery = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name CurrentMajorVersionNumber, CurrentMinorVersionNumber, CurrentBuildNumber, UBR -ErrorAction SilentlyContinue
    if ($?) { #checks execution status of last command
        $buildData = '{0}.{1}' -f $registryQuery.CurrentBuildNumber, $registryQuery.UBR
        return $buildData
    } else {
        return "Unable to fetch Current Build Version and Update Build Revision [UBR]"
    }

}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~GetLatestVersion Function~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Invokes a web request to scrape the Windows 11 History page for the newest update: https://support.microsoft.com/en-us/topic/windows-11-version-23h2-update-history-59875222-b990-4bd9-932f-91a5954de434
function GetLatestVersions {
    $webRequest = Invoke-WebRequest -URI https://learn.microsoft.com/en-us/windows/release-health/windows11-release-information
    $parse = $webRequest.ParsedHtml.getElementsByTagName("td")
    $count = 0
    $latestVersion = @()
    foreach ($string in $parse){
        if ($string.innerHTML -match "\."){
            $count += 1
            $latestVersion += $string.innerHTML
        }
        if ($count -eq 3){
            return $latestVersion
            break
        }
    }
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~M A I N~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Defines main test result variable
$osCheck = "Fail"

# Defines devices current version
# $currentVersion = GetBuildData
$currentVersion = "22631.3810"
Write-Host "Device's Current Windows OS Build: $($currentVersion)" -ForegroundColor DarkCyan

# Defines the value of the latest version from Microsoft's public release history
$latestVersions = GetLatestVersions
Write-Host "List of Latest Windows Builds: $($latestVersions)" -ForegroundColor DarkRed

if ($currentVersion -in $latestVersions) {
    $osCheck = "Pass"
}

Write-Output $osCheck