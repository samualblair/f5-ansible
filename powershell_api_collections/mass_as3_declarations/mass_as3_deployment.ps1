#!/bin/pwsh
# Name: mass_as3_deployment.ps1
# Author Michael Johnson 05-30-2026
# Simple Script to easily perform mass AS3 declarations from system with PowerShell
# Script recursively finds AS3 Declarations and Posts them all to a single F5 BIG-IP using AS3 API

# ############# STEP 0 #############
# Create a List for Declaration IDs
$listOfDeclarationIDs = [System.Collections.Generic.List[string]]::new()
# Create a List files Declaration IDs
$filenameList = [System.Collections.Generic.List[string]]::new()


# ############# STEP 1 Login #############

# Prompt User Details
Write-Host "Base Folder for Recursive AS3 Deployment for example - Must be Folder ending in '\' or '/' : '../AS3_Files/' or 'C:\AS3_files\'"
Write-Host "NOTE: Must be Folder Path ending in '\' or '/' such as: '../AS3_Files/' or 'C:\AS3_files\'"
$f5_as3_base_folder = Read-Host "Enter Base Folder"
$f5Hostname = Read-Host "Enter F5 Hostname or IP Address"
$f5_username = Read-Host "Enter F5 User Name (e.g. admin)"
$f5_password = Read-Host "Enter F5 Password" -MaskInput
# TODO: Future PS7 and above only Consider using -AsSecureString but then would also need to use ConvertFrom-SecureString -SecureString $secureString -AsPlainText


# Prepare Login API Call
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Content-Type", "application/json")

$body = @"
{
    `"username`": `"$f5_username`",
    `"password`": `"$f5_password`",
    `"loginProviderName`": `"tmos`"
}
"@

# Perform Login API Call
$response = Invoke-RestMethod "https://$f5Hostname`:443/mgmt/shared/authn/login" -Method 'POST' -Headers $headers -Body $body -SkipCertificateCheck
# $response | ConvertTo-Json
$responseToken = $response.token.token
# $responseToken | ConvertTo-Json
Write-Host "Login Process Finished"
Write-Host "`n"

# ############# STEP 2 Check Status #############

# Prepare Service Info/Status Check API Call
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("X-F5-Auth-Token", "$responseToken")

# Perform Service Info/Status Check API Call
$response = Invoke-RestMethod "https://$f5Hostname`:443/mgmt/shared/appsvcs/info" -Method 'GET' -Headers $headers -SkipCertificateCheck
Write-Host "AS3 Service Status:"
$response | ConvertTo-Json
Write-Host "`n"

# ############# STEP 3 Perform Declaration and Job Status Check #############

# Built List of filenames
$partialFileNameList = Get-ChildItem -Path $f5_as3_base_folder -Name -Recurse -Attributes !Directory
# Build full list with relative path names
foreach ($partialFileName in $partialFileNameList) {
    $filenameList.Add($f5_as3_base_folder+$partialFileName)
}

# Inform User of Files Found
Write-Host "Found the following AS3 Files:"
Write-Host $filenameList -Separator "`n"
Write-Host "`n"

# Loop through Declaration of Each File
foreach ($filename in $filenameList) {

    # Prepare AS3 Declaration API Call
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("X-F5-Auth-Token", "$responseToken")
    $headers.Add("Content-Type", "application/json")
    # Load Body
    $body = Get-Content $filename
    # Perform Declaration
    $response = Invoke-RestMethod "https://$f5Hostname`:443/mgmt/shared/appsvcs/declare?async=true" -Method 'POST' -Headers $headers -Body $body -SkipCertificateCheck
    # $response | ConvertTo-Json
    $responseDeclarationID = $response.id
    # $responseDeclarationID | ConvertTo-Json    
    $listOfDeclarationIDs.Add($responseDeclarationID)
    Write-Host "Waiting 3 seconds - First sleep"
    Start-Sleep -Seconds 3

    # Prepare AS3 Task/Job Check API Call
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("X-F5-Auth-Token", "$responseToken")
    # Perform Check
    $response = Invoke-RestMethod "https://$f5Hostname`:443/mgmt/shared/appsvcs/task/$responseDeclarationID" -Method 'GET' -Headers $headers -SkipCertificateCheck

    # First Attempt to wait and retry
    if ("in progress" -eq $response.results.message) {
        Write-Host "Waiting 3 seconds - Second sleep"
        Start-Sleep -Seconds 3
        $response = Invoke-RestMethod "https://$f5Hostname`:443/mgmt/shared/appsvcs/task/$responseDeclarationID" -Method 'GET' -Headers $headers -SkipCertificateCheck
    }
    # Last Attempt to wait and retry
    if ("in progress" -eq $response.results.message) {
        Write-Host "Waiting 4 seconds - Final sleep"
        Start-Sleep -Seconds 4
        $response = Invoke-RestMethod "https://$f5Hostname`:443/mgmt/shared/appsvcs/task/$responseDeclarationID" -Method 'GET' -Headers $headers -SkipCertificateCheck
    }
    $response.id | ConvertTo-Json
    $response.results | ConvertTo-Json
    Write-Host "`n"

}



# ############# STEP 4 Check Job Status #############

# Loop through Status Check of of Each File
# foreach ($responseDeclarationID in $listOfDeclarationIDs) {
# }



# ############# Step 5 - Print out or Save All Declarations Made #############
Write-Host "List of all Declaration Job IDs:"
Write-Host $listOfDeclarationIDs -Separator "`n"
Write-Host "`n"
