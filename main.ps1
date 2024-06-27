<#
Author: Ainsley Cabading
Script: main.ps1

Function: 
- Main Powershell script that runs everything

Result: connectToIntranet [Pass/Fail]
#>

#Calling the various check scripts

$osCheck = & "winspect\os.ps1"
$localityCheck = & "winspect\locality.ps1"
$secprodCheck = & "winspect\secprod.ps1"

$checks = @($osCheck, $localityCheck, $secprodCheck)

$connectToIntranet = "Fail"

if ($connectToIntranet -notin $checks) {
    $connectToIntranet = "Pass"
    Write-Host "Welcome to the GovTech Intranet." -ForegroundColor Green
} else {
    Write-Host "You are not authorized to access the GovTech Intranet. Please revise your device's security." -ForegroundColor Red
}