
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

function Get-PromotionCandidates {
    $promotedDeploymentsResponse = (Invoke-WebRequest -Uri "$branchUrl/api/deployments?projects=$promotionProjectId&environments=$dockerhubEnvironmentId" -Headers @{ "X-Octopus-ApiKey"=$branchApiKey }).Content | ConvertFrom-Json
    $promotedReleases = $promotedDeploymentsResponse.Items | Select-Object -ExpandProperty "ReleaseId" -Unique

    $allReleasesResponse = (Invoke-WebRequest -Uri "$branchUrl/api/deployments?projects=$promotionProjectId" -Headers @{ "X-Octopus-ApiKey"=$branchApiKey }).Content | ConvertFrom-Json
    $allReleases = $allReleasesResponse.Items | Select-Object -ExpandProperty "ReleaseId" -Unique

    $candidates = $allReleases | Where-Object { -not ($_ -in $promotedReleases) } 

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

function Get-CachedImageVersions() {
    
}

Get-ProductionDWVersions
