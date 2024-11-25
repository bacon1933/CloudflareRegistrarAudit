$accountID = "accountID"
$token = "token"
$APIKey = "APIKey"
$email = "email"

$URIListDomainReg = "https://api.cloudflare.com/client/v4/accounts/$accountID/registrar/domains/?per_page=200"
$URIListZones = "https://api.cloudflare.com/client/v4/zones?per_page=700"
$URIGetDomainReg = "https://api.cloudflare.com/client/v4/accounts/$accountID/registrar/domains/$domainName"
$URIDNS = "https://api.cloudflare.com/client/v4/zones/$zoneID/dns_records"
$URIZoneDetails = "https://api.cloudflare.com/client/v4/zones/$zoneID"

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
    "X-Auth-Email" = "$email"
    "X-Auth-Key" = "$APIKey"
}


$response = Invoke-RestMethod -Method GET -Uri $URIListZones -Headers $headers -ContentType "application/json"
$zones = $response.result.id
$domainNames = @()

foreach ($zone in $zones) {
    $zoneURI = "https://api.cloudflare.com/client/v4/zones/" + "$zone"
    $zoneResponse = Invoke-RestMethod -Method GET -Uri $zoneURI -Headers $headers -ContentType "application/json"

    $domainNames += $zoneResponse.result.name
}


$registrarList = @()

foreach ($domain in $domainNames) {

    $DomainResultURI = "https://api.cloudflare.com/client/v4/accounts/$accountID/registrar/domains/" + "$domain"
    $DomainResults = Invoke-RestMethod -Method GET -Uri $DomainResultURI -Headers $headers -ContentType "application/json"

    $domainData = [PSCustomObject]@{
        Domain = $DomainResults.result.name
        Current_Registrar = $DomainResults.result.current_registrar
        Previous_Registrar = $DomainResults.result.previous_registrar
        Created_At = $DomainResults.result.created_at
        Name_Servers   = $DomainResults.result.name_servers
    }
    $registrarList += $domainData
}

$registrarList | Export-Csv -Path "RegistrarAudit.csv" -NoTypeInformation -Encoding UTF8
