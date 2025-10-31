$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("X-F5-Auth-Token", "$responseToken")
$headers.Add("Content-Type", "application/json")

$body = @"
{
    `"`$schema`": `"https://raw.githubusercontent.com/F5Networks/f5-declarative-onboarding/master/src/schema/latest/base.schema.json`",
    `"schemaVersion`": `"1.26.0`",
    `"class`": `"Device`",
    `"async`": true,
    `"controls`": {
        `"trace`": true
    },
    `"Common`": {
        `"class`": `"Tenant`",
         `"DNS`": {
            `"class`": `"DNS`",
            `"nameServers`": [
                `"8.8.8.8`",
                `"1.1.1.1`",
                `"9.9.9.9`"
            ],
            `"search`": [
                `"domain.local`"
            ]
        },
        `"System`": {
            `"class`": `"System`",
            `"hostname`": `"EXAMPLE.HOST.NAME`",
            `"autoCheck`": true,
            `"autoPhonehome`": true
        },
        `"NTP`": {
            `"class`": `"NTP`",
            `"servers`": [
                `"pool.ntp.org`",
                `"0.pool.ntp.org`",
                `"1.pool.ntp.org`"
            ],
            `"timezone`": `"US/Pacific`"
        }
    }
}
"@

$response = Invoke-RestMethod "https://$f5Hostname`:443/mgmt/shared/declarative-onboarding" -Method 'POST' -Headers $headers -Body $body
# $response | ConvertTo-Json
$responseDeclarationID = $response.id
$responseDeclarationID | ConvertTo-Json
