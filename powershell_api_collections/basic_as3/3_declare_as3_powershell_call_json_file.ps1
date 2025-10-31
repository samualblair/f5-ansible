$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("X-F5-Auth-Token", "$responseToken")
$headers.Add("Content-Type", "application/json")
# If needed remove content type header
# $headers.Remove("Content-Type")

$filename = "{{C:/Users/UserName/Downloads/declare.as3.json}}"
$body = Get-Content $filename

$response = Invoke-RestMethod "https://$f5Hostname`:443/mgmt/shared/appsvcs/declare?async=true" -Method 'POST' -Headers $headers -Body $body
# $response | ConvertTo-Json
$responseDeclarationID = $response.id
$responseDeclarationID | ConvertTo-Json
