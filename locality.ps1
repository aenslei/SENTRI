<#
Author: Ainsley Cabading
Script: locality.ps1

Function: 
- Checks for a device's network locality by extracting a JSON response from http://ip-api.com/json/. 
- Iterates through the UN Sanctions list to determine whether traffic is to be blocked or not.

Result: localityCheck [Success/Fail]
#>

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~GetLocation Function~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Sends web request to API for geo-information and stores JSON response in a PSCustomObject for future reference.
function GetGeolocation {

    param (
        [string]$URL
    )

    try {
        $response = Invoke-RestMethod -Uri $URL
    if ($response.status -eq "success") {
        return [PSCustomObject]@{
            Status  = $response.status
            Country = $response.country
        }
        }
    } catch {
        # Handling exceptions
        Write-Host "An error has occured."
    }
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~CheckUNSanction Function~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Iterates through list of UN Sanctioned countries. Checks if client geolocation is within sanctions list

function CheckUNSanction {
    param (
        [string]$country,
        [array]$sanctionList
    )

    $result = "Pass"

    foreach ($item in $sanctionList) {
        if ($item -eq $country) {
            $result = "Fail"
        }
    }

    return $result
}

# Defining main localityCheck variable
$localityCheck = "Fail"

# Defining the URL of the geolocation API
$ipAPI = "http://ip-api.com/json/?fields=status,message,country,query"

# Defining API response value from GetGeolocation
$response = GetGeolocation -URL $ipAPI
$country = $response.country

# Defining array of country names that are under the UN Sanctions list in UNSanction array.
$UNSanction = "Central African Republic", "Democratic Republic of Congo", "Eritrea", "Guinea-Bissau", "Iran", "Iraq", "Lebanon", "Libya", "Mali", "North Korea", "Russia", "Somalia", "South Sudan", "Sudan", "Yemen"

# Defining response from CheckUNSanction to determine value of localityCheck
$sanctionCheck = CheckUNSanction -country $country -sanctionList $UNSanction
if ($sanctionCheck -eq "Pass") {
    $localityCheck = "Pass"
}

Write-Host "Result of Locality Check: $($localityCheck)" -ForegroundColor Magenta