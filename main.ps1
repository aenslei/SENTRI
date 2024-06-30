<#
Author: Ainsley Cabading
Script: main.ps1

Function: 
- Main Powershell script that runs everything

Result: connectToIntranet [Pass/Fail]
#>

#Calling the various check scripts

$welcome = @"
main.ps1: Running...

  ____________________ ____________________________.___ 
 /   _____/\_   _____/ \      \__    ___/\______   \   |
 \_____  \  |    __)_  /   |   \|    |    |       _/   |
 /        \ |        \/    |    \    |    |    |   \   |
/_______  //_______  /\____|__  /____|    |____|_  /___|
        \/         \/         \/                 \/     

"@

$passText = @"

_________                                     __  .__                ___________         __        ___.   .__  .__       .__               .___
\_   ___ \  ____   ____   ____   ____   _____/  |_|__| ____   ____   \_   _____/ _______/  |______ \_ |__ |  | |__| _____|  |__   ____   __| _/
/    \  \/ /  _ \ /    \ /    \_/ __ \_/ ___\   __\  |/  _ \ /    \   |    __)_ /  ___/\   __\__  \ | __ \|  | |  |/  ___/  |  \_/ __ \ / __ | 
\     \___(  <_> )   |  \   |  \  ___/\  \___|  | |  (  <_> )   |  \  |        \\___ \  |  |  / __ \| \_\ \  |_|  |\___ \|   Y  \  ___// /_/ | 
 \______  /\____/|___|  /___|  /\___  >\___  >__| |__|\____/|___|  / /_______  /____  > |__| (____  /___  /____/__/____  >___|  /\___  >____ | 
        \/            \/     \/     \/     \/                    \/          \/     \/            \/    \/             \/     \/     \/     \/ 
main.ps1: Connection Established. Welcome to the Internal Network, User.

"@

$failText = @"

___________                  _____                .__        
\__    ___/______ ___.__.   /  _  \    _________  |__| ____  
  |    |  \_  __ <   |  |  /  /_\  \  / ___\__  \ |  |/    \ 
  |    |   |  | \/\___  | /    |    \/ /_/  > __ \|  |   |  \
  |____|   |__|   / ____| \____|__  /\___  (____  /__|___|  /
                  \/              \//_____/     \/        \/ 

main.ps1: Connection Failed. Please revise your device's security and try again.
"@

Write-Host $welcome -ForegroundColor DarkBlue

$osCheck = & "os.ps1"
$localityCheck = & "locality.ps1"
$secprodCheck = & "secprod.ps1"

$checks = @($osCheck, $localityCheck) # $secprodCheck

$connectToIntranet = "Fail"

if ($connectToIntranet -notin $checks) {
    $connectToIntranet = "Pass"
    Write-Host $passText -ForegroundColor Green
} else {
    Write-Host $failText -ForegroundColor Red
}
