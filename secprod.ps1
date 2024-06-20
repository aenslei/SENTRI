<#
Author: Ainsley Cabading
Script: secprod.ps1

Function: 
- Checks whether a client device has the necessary security products to ensure a secure connection
to the company intranet


Result: secprodCheck [Success/Fail]
#>

##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Find-MatchingProperty Function~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Finds if there are any key properties that contain the substring being checked.
# This will be used to check for either ProductVersion or Version, as different products use different property names
function Find-MatchingProperty {
    param (
        [psobject]$properties,
        [string[]]$substrings
    )

    foreach ($substring in $substrings) {
        $matchingProperty = $properties.PSObject.Properties | Where-Object { $_.Name -like "*$substring*" }
        if ($matchingProperty) {
            return $matchingProperty.Value
        }
    }
}

##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~QueryRegistry Function~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Queries the Windows Registry path and displays it's values to see whether it exists or not

function QueryRegistry {
    param (
        [string]$Path
    )

    #result, being either Empty or Exists determines whether the registry path exists or not
    $result = "Empty"

    #keyProperties hashtable to hold key's Name and Version data
    $keyProperties = @{}

    #Substring arrays
    $nameSubstrings = @("ProductName", "Name")
    $versionSubstrings = @("ProductVersion", "Version")

    try {
        #Extracts key with Get-Item
        $key = Get-Item -Path $Path

        #If key exists
        if ($key -ne $null) {
            #Sets result to Exists as key is NOT null
            $result = "Exists"

            #Gets key properties and finds product name and version data
            $properties = $key | Get-ItemProperty
            $productName = Find-MatchingProperty -properties $properties -substrings $nameSubstrings
            $productVersion = Find-MatchingProperty -properties $properties -substrings $versionSubstrings
            
            $keyProperties['ProductName'] = $productName
            $keyProperties['ProductVersion'] = $productVersion

            #return an object with the keyProperties IF result = "Exists"
            return [PSCustomObject]@{
                queryResult = $result
                keyProperties = $keyProperties
        }
        }

        #if key does not exist
        else {
            return [PSCustomObject]@{
                queryResult = $result
                keyProperties = $keyProperties
        }
        }
    
    } catch {
        Write-Host "An error has occured" -ForegroundColor DarkRed
    }
}

# Defining secprodCheck value
$secprodCheck = "Fail"

# Defining array of registry paths to check
$registryPaths = @("HKLM:\SOFTWARE\Microsoft\Windows Defender", "HKLM:\SOFTWARE\ExpressVPN", "HKLM:\SOFTWARE\Norton\{XXXXX-XXXXX-XXXXX-XXXX-XXX}")
    # Will take off Windows Defender till I find a registry key that has Name and Version
    # "Windows Defender" = @(
    #     "HKLM:\SOFTWARE\Microsoft\Windows Defender"

# Iterate through each key and determine their value. Ultimately determines value of secprodCheck 
foreach ($registryPath in $registryPaths) {
    $pathQueryResponse = QueryRegistry -path $registryPath
    #if any key is null, secprodCheck sticks to Fail value
    if ($pathQueryResponse.queryResult -eq "Exists") {
        # For now, skip checking latest version using keyProperties.ProductVersion
        # $keyProperties = $pathQueryResponse.keyProperties

        $secprodCheck = "Pass"
        
    } else {
        $secprodCheck = "Fail"
    }
}

Write-Host "Result of Security Product Check: $($secprodCheck)" -ForegroundColor Magenta