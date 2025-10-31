$f5Hostname = "{{f5_hostname}}"
$f5_username = "{{f5_user_name}}"
$f5_password =  "{{f5_password}}"

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Content-Type", "application/json")

$body = @"
{
    `"username`": `"$f5_username`",
    `"password`": `"$f5_password`",
    `"loginProviderName`": `"tmos`"
}
"@

$response = Invoke-RestMethod "https://$f5Hostname`:443/mgmt/shared/authn/login" -Method 'POST' -Headers $headers -Body $body
# $response | ConvertTo-Json
$responseToken = $response.token.token
$responseToken | ConvertTo-Json
