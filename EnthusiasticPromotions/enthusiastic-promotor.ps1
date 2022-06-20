using module .\enthusiastic-promotor.psm1

[CmdletBinding()]
param (
    [Parameter()][string] $dynamicWorkerInstanceApiKey = "",
    [Parameter()][string] $dynamicWorkerInstanceUrl = "https://deploy.octopus.app",
    [Parameter()][string] $dynamicWorkerProjectId   = "Projects-5063",
    [Parameter()][string] $dynamicWorkerSpaceId     = "Spaces-142",

    [Parameter()][string] $targetInstanceApiKey = "",
    [Parameter()][string] $targetInstanceUrl        = "https://deploy-fnm.testoctopus.app",
    [Parameter()][string] $targetProjectId          = "Projects-381",
    [Parameter()][string] $targetSpaceId            = "Spaces-1",
    [Parameter()][string] $runbookProjectId         = "Projects-386",

    [Parameter()][string] $targetProjectTestEnvironment = "Environments-61",
    [Parameter()][string] $targetProjectProdEnvironment = "Environments-62"
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

function Get-PromotionCandidates([Release[]]$dynamicWorkerReleases, [Deployment[]]$dynamicWorkerDeployments) {
    if ($dynamicWorkerReleases.Count -eq 0 -or $dynamicWorkerDeployments.Count -eq 0) {
        return
    }

    $uniqueReleases = $dynamicWorkerReleases | Select-Object Property "ReleaseId" -Unique
    $promotedReleases = $dynamicWorkerDeployments | Select-Object -Property "ReleaseId" -Unique

    $candidates = $uniqueReleases | Where-Object { -not ($_ -in $promotedReleases) } 

    Write-Host $candidates
}

function Get-ProductionDWVersions {
    $releases = @();

    foreach ($tenant in $productionTenants) {
        $releasesInProductionResponse = Get-FromApi "$dynamicWorkerInstanceUrl/api/$dynamicWorkerSpaceId/deployments?projects=$dynamicWorkerProjectId&environments=$productionEnvironmentId&tenants=$tenant" $dynamicWorkerInstanceApiKey
        $release = $releasesInProductionResponse.Items | Sort-Object -Property "Created" -Descending | Select-Object -First 1
        
        $releases += $release
    }

    Write-Host ($releases | Select-Object -ExpandProperty "ReleaseId")
}

function Get-Release($projectId, $baseUrl, $apiToken) {
    $releasesResponse = Get-FromApi "$baseUrl/api/projects/$projectId" $targetInstanceApiKey
    $releasesResponse.Items | Foreach-Object { [Release]::new($_.Id, $_.ProjectId) }
}

function Get-Deployment($projectId, $environment, $baseUrl, $apiToken) {
    $deploymentsResponse = Get-FromApi "$targetInstanceUrl/api/deployments?projects=$targetProjectId&environments=$dockerhubEnvironmentId" $targetInstanceApiKey
    $deploymentsResponse.Items | Foreach-Object { [Deployment]::new($_.Id, $_.ReleaseId, $_.EnvironmentId) }
}

$dynamicWorkerReleases      = Get-Release $targetProjectId $targetInstanceUrl $targetInstanceApiKey
$dynamicWorkerDeployments   = Get-Deployment $targetProjectId $dockerhubEnvironmentId $targetInstanceUrl $targetInstanceApiKey
