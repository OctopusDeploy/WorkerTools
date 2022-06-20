[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)][string] $dynamicWorkerInstanceApiKey,
    [Parameter()][string] $dynamicWorkerInstanceUrl = "https://deploy.octopus.app",
    [Parameter()][string] $dynamicWorkerProjectId   = "Projects-5063",
    [Parameter()][string] $dynamicWorkerSpaceId     = "Spaces-142",

    [Parameter(Mandatory = $true)][string] $targetInstanceApiKey,
    [Parameter()][string] $targetInstanceUrl        = "https://deploy-fnm.testoctopus.app",
    [Parameter()][string] $targetProjectId          = "Projects-381",
    [Parameter()][string] $targetSpaceId            = "Spaces-1",
    [Parameter()][string] $runbookProjectId         = "Projects-386"
)

$dockerhubEnvironmentId = "Environments-62"
$productionEnvironmentId = "Environments-842"
$productionTenants = @("Tenants-8286", "Tenants-8287", "Tenants-8288")

function Get-FromApi($url, $apiKey) {
    Write-Verbose "Getting response from $url"
    # $result = Invoke-RestMethod -Uri $url -Headers @{ 'X-Octopus-ApiKey' = $enthusiasticPromoterApiKey } -TimeoutSec 60 -RetryIntervalSec 10 -MaximumRetryCount 2

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
        $releasesInProductionResponse = (Invoke-WebRequest -Uri "$dynamicWorkerInstanceUrl/api/$dynamicWorkerSpaceId/deployments?projects=$dynamicWorkerProjectId&environments=$productionEnvironmentId&tenants=$tenant" -Headers @{ "X-Octopus-ApiKey"=$dynamicWorkerInstanceApiKey }).Content | ConvertFrom-Json
        $release = $releasesInProductionResponse.Items | Sort-Object -Property "Created" -Descending | Select-Object -First 1
        
        $releases += $release
    }

    Write-Host ($releases | Select-Object -ExpandProperty "ReleaseId")
}

$dynamicWorkerReleases      = Get-FromApi "$targetInstanceUrl/api/deployments?projects=$targetProjectId" $targetInstanceApiKey
$dynamicWorkerDeployments   = Get-FromApi "$targetInstanceUrl/api/deployments?projects=$targetProjectId&environments=$dockerhubEnvironmentId" $targetInstanceApiKey
