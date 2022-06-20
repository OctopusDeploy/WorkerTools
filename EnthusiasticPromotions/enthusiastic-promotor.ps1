
$promotionProjectId = "Projects-386"
$dockerhubEnvironmentId = "Environments-62"

$hostedSpace = "Spaces-142"
$dwProjectId = "Projects-5063"
$productionEnvironmentId = "Environments-842"
$productionTenants = @("Tenants-8286", "Tenants-8287", "Tenants-8288")

$branchUrl = "https://deploy-fnm.testoctopus.app"
$branchApiKey = "API-Key"

$deployUrl = "https://deploy.octopus.app"
$deployApiKey = "API-Key"

function Get-FromApi($url, $apiKey) {
    Write-Verbose "Getting response from $url"
    $result = Invoke-RestMethod -Uri $url -Headers @{ 'X-Octopus-ApiKey' = $enthusiasticPromoterApiKey } -TimeoutSec 60 -RetryIntervalSec 10 -MaximumRetryCount 2

    # log out the  json, so we can diagnose what's happening / write a test for it
    write-verbose "--------------------------------------------------------"
    write-verbose "response:"
    write-verbose "--------------------------------------------------------"
    write-verbose ($result | ConvertTo-Json -depth 10)
    write-verbose "--------------------------------------------------------"
    return $result
}

function Get-PromotionCandidates($dynamicWorkerReleases, $dynamicWorkerDeployments) {
    
    $uniqueReleases = $dynamicWorkerReleases.Items | Select-Object -ExpandProperty "ReleaseId" -Unique
    $promotedReleases = $dynamicWorkerDeployments.Items | Select-Object -ExpandProperty "ReleaseId" -Unique

    $candidates = $uniqueReleases | Where-Object { -not ($_ -in $promotedReleases) } 

    Write-Host $candidates
}

function Get-ProductionDWVersions {
    $releases = @();

    foreach ($tenant in $productionTenants) {
        $releasesInProductionResponse = (Invoke-WebRequest -Uri "$deployUrl/api/$hostedSpace/deployments?projects=$dwProjectId&environments=$productionEnvironmentId&tenants=$tenant" -Headers @{ "X-Octopus-ApiKey"=$deployApiKey }).Content | ConvertFrom-Json
        $release = $releasesInProductionResponse.Items | Sort-Object -Property "Created" -Descending | Select-Object -First 1
        
        $releases += $release
    }

    Write-Host ($releases | Select-Object -ExpandProperty "ReleaseId")
}

function Execute {
    $dynamicWorkerReleases      = Get-FromApi "$branchUrl/api/deployments?projects=$promotionProjectId" $branchApiKey
    $dynamicWorkerDeployments   = Get-FromApi "$branchUrl/api/deployments?projects=$promotionProjectId&environments=$dockerhubEnvironmentId" $branchApiKey

    Get-ProductionDWVersions
}