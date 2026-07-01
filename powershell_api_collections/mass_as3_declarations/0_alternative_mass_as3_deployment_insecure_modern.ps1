# ############# STEP 0 #############
# Create a List of Declaration IDs
$listOfDeclarationIDs = [System.Collections.Generic.List[string]]::new()



# ############# STEP 1 Login #############

# Prompt User Details
Write-Host "Base Folder for Recursive AS3 Deployment for example: '../AS3_Files/' or 'C:\AS3_files\'"
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
$responseToken | ConvertTo-Json



# ############# STEP 2 Check Status #############

# Prepare Service Info/Status Check API Call
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("X-F5-Auth-Token", "$responseToken")

# Perform Service Info/Status Check API Call
$response = Invoke-RestMethod "https://$f5Hostname`:443/mgmt/shared/appsvcs/info" -Method 'GET' -Headers $headers -SkipCertificateCheck
$response | ConvertTo-Json



# ############# STEP 3 Perform Declaration #############

# Prepare AS3 Declaration API Call
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("X-F5-Auth-Token", "$responseToken")
$headers.Add("Content-Type", "application/json")
# If needed remove content type header
# $headers.Remove("Content-Type")

# $filename = "{{C:/Users/UserName/Downloads/declare.as3.json}}"
# LIST OF FILENAMES FOR TESTING

$filenameList = [System.Collections.Generic.List[string]]::new()

# Built List of filenames
$partialFileNameList = Get-ChildItem -Path $f5_as3_base_folder -Name -Recurse -Attributes !Directory
# Build full list with relative path names
foreach ($partialFileName in $partialFileNameList) {
    $filenameList.Add($f5_as3_base_folder+$partialFileName)
}

# Inform User of Files Found
Write-Host "Found the following AS3 Files:"
Write-Host $filenameList -Separator "`n"

# Loop through Declaration of Each File
foreach ($filename in $filenameList) {
    $body = Get-Content $filename

    $response = Invoke-RestMethod "https://$f5Hostname`:443/mgmt/shared/appsvcs/declare?async=true" -Method 'POST' -Headers $headers -Body $body -SkipCertificateCheck
    # $response | ConvertTo-Json
    $responseDeclarationID = $response.id
    $responseDeclarationID | ConvertTo-Json    
    $listOfDeclarationIDs.Add($responseDeclarationID)
    Start-Sleep -Seconds 10
}



# ############# STEP 4 Check Job Status #############

# Prepare AS3 Task/Job Check API Call
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("X-F5-Auth-Token", "$responseToken")

# Loop through Status Check of of Each File
foreach ($responseDeclarationID in $listOfDeclarationIDs) {
    $response = Invoke-RestMethod "https://$f5Hostname`:443/mgmt/shared/appsvcs/task/$responseDeclarationID" -Method 'GET' -Headers $headers -SkipCertificateCheck
    $response.id | ConvertTo-Json
    $response.results | ConvertTo-Json
}



# ############# Optional Step 5 - Print out or Save All Declarations Made #############
# $listOfDeclarationIDs
