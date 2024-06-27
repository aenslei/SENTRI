<#
Author: Ainsley Cabading
Script: secprod.ps1

Author's Note: 
- I will admit, this check script is a little wonky. It's not as dynamic as I'd like it to be,
but I make do with the tools that I test for and the power of web scraping.
If you want to try the tool without this script irst, simply remove the secprodCheck variable in main.ps1 > $checks.

- For the Registry Path of Norton 360, I believe each user will have a different number within the { }.

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

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~QueryRegistry Function~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~NortonLatestVersion Function~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Queries the Norton Community blog website to extract the latest version through webscraping

function NortonLatestVersion {
    #Declares variables
    $webRequest = Invoke-WebRequest -URI 'https://community.norton.com/en/blogs/product-update-announcements/?f%5B0%5D=im_field_content_labels%3A7243&f%5B1%5D=im_field_content_labels%3A14101'
    $parse = $webRequest.ParsedHtml.getElementsByTagName("h3")
    $count = 0
    $pattern = 'Norton Security (\d+\.\d+\.\d+\.\d+) for Windows is now available!'
    $latestVersion = @()

    # Iterates through each string from the parsed HTML response and looks for the 1st instance of <h3>
    foreach ($string in $parse){
        if ($string.innerHTML -match $pattern){
            $count += 1
            $latestVersion += $string.innerHTML
        }
        if ($count -eq 1){
            # Uses regex to capture the version number X.X.X.X from inside the <h3>
            $matches = [regex]::Matches($string.innerHTML, $pattern)
            $latestVersion = $matches[0].Groups[1].Value
            return $latestVersion
            break
        }
    }
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ExpressVPNLatestVersion Function~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Queries the Norton Community blog website to extract the latest version through webscraping

function ExpressVPNLatestVersion {
    #Declares variables
    $htmlContent = ConvertFrom-HTML -URL "https://www.expressvpn.com/support/vpn-setup/release-notes/windows-app/" -Engine AngleSharp
    $regexPattern = '<strong>(.*?)</strong>'

    # Iterates through HTML response and looks for 1st instance of <strong>, then takes inner value
    if ($htmlContent.InnerHtml -match $regexPattern) {
        # Output the content inside the first <strong> tag
        $strongContent = $matches[1]
        return $strongContent
    } else {
        Write-Output "No <strong> tag found."
    }
    
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~M A I N~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Defining secprodCheck value
$secprodCheck = "Fail"

# Defining array of versions to check
$registryPaths = @("HKLM:\SOFTWARE\ExpressVPN", "HKLM:\SOFTWARE\Norton\{REDACTED-REDACTED-REDACTED-REDACTED-REDACTED}")
#removed "HKLM:\SOFTWARE\Microsoft\Windows Defender", 

#Defining Product Names and Latest Versions
$productNames  = @("ExpressVPN", "Norton Security")
$NortonLatest = NortonLatestVersion
$ExpressLatest = ExpressVPNLatestVersion
$ExpressCurrent = (Invoke-Expression ".\ExpressVPN.cli --version") -match "\d+\.\d+\.\d+\.\d+"; $matches[0]
$productLatestVersions = @($($NortonLatest), $($ExpressLatest) )

# Iterate through each key and determine their properties. Ultimately determines value of secprodCheck 
foreach ($registryPath in $registryPaths) {
    # Queries registry for key values
    $pathQueryResponse = QueryRegistry -path $registryPath

    if ($pathQueryResponse.queryResult -eq "Exists") {
        #Extracts key properties from the query response
        $keyProperties = $pathQueryResponse.keyProperties

        if (($keyProperties.ProductName -in $productNames)) {
            
            #For ExpressVPN, can't check ver thru reg, so need do CLI cmd, hence need to check for it indiv
            if (ExpressCurrent -eq $ExpressLatest) {
                
                if ($keyProperties.ProductVersion -in $productLatestVersions) {
                    $secprodCheck = "Pass"
                }

            }
        }
    } else {
        $secprodCheck = "Fail"
    }
}

Write-Host "Result of Security Product Check: $($secprodCheck)" -ForegroundColor DarkYellow

Write-Output $secprodCheck