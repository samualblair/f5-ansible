#!/bin/pwsh
# Name: mass_as3_deployment.ps1
# Author Michael Johnson 06-01-2026
# Simple Script to easily perform mass AS3 declarations from system with PowerShell
# Script recursively finds AS3 Declarations and Posts them all to a single F5 BIG-IP using AS3 API

# ############# STEP 0 #############
# Create a List of Declaration IDs
$listOfDeclarationIDs = [System.Collections.Generic.List[string]]::new()
# Create a List files Declaration IDs
$filenameList = [System.Collections.Generic.List[string]]::new()

# Prepare for Insecure Connections - workaround on PowerShell 5 and earlier
if (-not("dummy" -as [type])) {
    add-type -TypeDefinition @"
using System;
using System.Net;
using System.Net.Security;
using System.Security.Cryptography.X509Certificates;

public static class Dummy {
    public static bool ReturnTrue(object sender,
        X509Certificate certificate,
        X509Chain chain,
        SslPolicyErrors sslPolicyErrors) { return true; }

    public static RemoteCertificateValidationCallback GetDelegate() {
        return new RemoteCertificateValidationCallback(Dummy.ReturnTrue);
    }
}
"@
}

[System.Net.ServicePointManager]::ServerCertificateValidationCallback = [dummy]::GetDelegate()



# ############# STEP 1 Login #############

# Prompt User Details
Write-Host "Base Folder for Recursive AS3 Deployment for example - Must be Folder ending in '\' or '/' : '../AS3_Files/' or 'C:\AS3_files\'"
Write-Host "NOTE: Must be Folder Path ending in '\' or '/' such as: '../AS3_Files/' or 'C:\AS3_files\'"
$f5_as3_base_folder = Read-Host "Enter Base Folder"
$f5Hostname = Read-Host "Enter F5 Hostname or IP Address"
$f5_username = Read-Host "Enter F5 User Name (e.g. admin)"
# Take in a secure string
$f5_password_input = Read-Host "Enter F5 Password" -AsSecureString
# Convert to insecure string for use with API
$f5_password_bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($f5_password_input)
# Convert to insecure string for use with API
$f5_password = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($f5_password_bstr)
# Free up the unused memory when no longer needed
[Runtime.InteropServices.Marshal]::ZeroFreeBSTR($f5_password_bstr)

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
$response = Invoke-RestMethod "https://$f5Hostname`:443/mgmt/shared/authn/login" -Method 'POST' -Headers $headers -Body $body
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
$response = Invoke-RestMethod "https://$f5Hostname`:443/mgmt/shared/appsvcs/info" -Method 'GET' -Headers $headers
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
    $response = Invoke-RestMethod "https://$f5Hostname`:443/mgmt/shared/appsvcs/declare?async=true" -Method 'POST' -Headers $headers -Body $body
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
    $response = Invoke-RestMethod "https://$f5Hostname`:443/mgmt/shared/appsvcs/task/$responseDeclarationID" -Method 'GET' -Headers $headers

    # First Attempt to wait and retry
    if ("in progress" -eq $response.results.message) {
        Write-Host "Waiting 3 seconds - Second sleep"
        Start-Sleep -Seconds 3
        $response = Invoke-RestMethod "https://$f5Hostname`:443/mgmt/shared/appsvcs/task/$responseDeclarationID" -Method 'GET' -Headers $headers
    }
    # Last Attempt to wait and retry
    if ("in progress" -eq $response.results.message) {
        Write-Host "Waiting 4 seconds - Final sleep"
        Start-Sleep -Seconds 4
        $response = Invoke-RestMethod "https://$f5Hostname`:443/mgmt/shared/appsvcs/task/$responseDeclarationID" -Method 'GET' -Headers $headers
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

# ############# Step 6 - CleanUp #############

# Free up the memory when no longer needed
Clear-Variable -Name "f5_password"
