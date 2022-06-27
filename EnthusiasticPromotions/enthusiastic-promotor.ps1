using module .\enthusiastic-promotor.psm1

[CmdletBinding()]
param (
    [Parameter()][string] $dynamicWorkerInstanceApiKey = "",
    [Parameter()][string] $dynamicWorkerInstanceUrl = "https://deploy.octopus.app",
    [Parameter()][string] $dynamicWorkerProjectId   = "Projects-5063",
    [Parameter()][string] $dynamicWorkerSpaceId     = "Spaces-142",

    [Parameter()][string] $dynamicWorkerProdEnvironment = "Environments-842",

    [Parameter()][string] $targetInstanceApiKey = "",
    [Parameter()][string] $targetInstanceUrl        = "https://deploy.octopus.app",
    [Parameter()][string] $targetProjectId          = "Projects-381",
    [Parameter()][string] $targetSpaceId            = "Projects-6481",
    [Parameter()][string] $runbookProjectId         = "",

    [Parameter()][string] $targetProjectTestEnvironment = "Environments-61",
    [Parameter()][string] $targetProjectProdEnvironment = "Environments-62"
)

$workerToolsProject = @{ 
    BaseUri = $targetInstanceUrl
    ApiKey = $targetInstanceApiKey
    ProjectId = $targetProjectId
    SpaceId = $targetSpaceId
}

$dynamicWorkerProject = @{ 
    BaseUri = $dynamicWorkerInstanceUrl
    ApiKey = $dynamicWorkerInstanceApiKey
    ProjectId = $dynamicWorkerProjectId
    SpaceId = $dynamicWorkerSpaceId 
    ProductionTenants = @("Tenants-8286", "Tenants-8287", "Tenants-8288")
}

function Get-FromApi($url, $apiKey) {
    Write-Verbose "Getting response from $url"
    $result = Invoke-RestMethod -Uri $url -Headers @{ 'X-Octopus-ApiKey' = $apiKey } -TimeoutSec 60 -RetryIntervalSec 10 -MaximumRetryCount 2

    # log out the  json, so we can diagnose what's happening / write a test for it
    Write-Debug "--------------------------------------------------------"
    Write-Debug "response:"
    Write-Debug "--------------------------------------------------------"
    Write-Debug ($result | ConvertTo-Json -depth 10)
    Write-Debug "--------------------------------------------------------"
    return $result
}

function Select-PromotionCandidates([Release[]]$workerToolReleases, [Deployment[]]$workerToolDeployments, [string]$testEnvironment, [string]$prodEnvironment) {
    if ($workerToolReleases.Count -eq 0 -or $workerToolDeployments.Count -eq 0) {
        return
    }

    $chronologicalReleases = $workerToolReleases | `
        Sort-Object -Property "Created", "ReleaseId" -PipelineVariable Release | `
        Foreach-Object { @{ 
            Release = $Release; 
            Deployments = ($workerToolDeployments | Where-Object { $_.ReleaseId -eq $Release.ReleaseId }) 
        } 
    }

    $candidateReleases = @()
    foreach ($release in $chronologicalReleases) {
        $deployedToEnvironments = $workerToolDeployments | Where-Object { $_.ReleaseId -eq $release.Release.ReleaseId } | Select-Object -ExpandProperty EnvironmentId

        if ($deployedToEnvironments -contains $testEnvironment) {
            if ($deployedToEnvironments -contains $prodEnvironment) {
                foreach ($supersededCandidate in $candidateReleases) {
                    Write-Verbose "Ignoring $($supersededCandidate.ReleaseId) because it is superseded by $($release.Release.ReleaseId), which was created later and has been fully promoted."
                }

                $candidateReleases = @()
            } else {
                $candidateReleases += $release.Release
            }
        }
    }

    $candidateReleases
}

function Select-ProductionDynamicWorkerRelease([Release[]]$dynamicWorkerReleases, [Deployment[]]$dynamicWorkerDeployments) {
    $releases = @();

    foreach ($tenant in $dynamicWorkerProductionTenants) {
        $releasesInProductionResponse = Get-FromApi "$dynamicWorkerInstanceUrl/api/$dynamicWorkerSpaceId/deployments?projects=$dynamicWorkerProjectId&environments=$dynamicWorkerProdEnvironment&tenants=$tenant" $dynamicWorkerInstanceApiKey
        $release = $releasesInProductionResponse.Items | Sort-Object -Property "Created" -Descending | Select-Object -First 1
        
        $releases += $release
    }

    Write-Host ($releases | Select-Object -ExpandProperty "ReleaseId")
}

function Get-Release($octopusProject) {
    $releasesResponse = Get-FromApi "$($octopusProject.BaseUri)/api/projects/$($octopusProject.ProjectId)/releases" $octopusProject.ApiKey
    $releasesResponse.Items | Foreach-Object { [Release]::new($_.Id, $_.ProjectId, $_.Assembled) }
}

function Get-Deployment($octopusProject) {
    $deploymentsResponse = Get-FromApi "$($octopusProject.BaseUri)/api/deployments?projects=$($octopusProject.ProjectId)" $octopusProject.ApiKey
    $deploymentsResponse.Items | Foreach-Object { [Deployment]::new($_.Id, $_.ReleaseId, $_.EnvironmentId) }
}

function Invoke-Promotions() {
    # Find our candidates for promotion
    $workerToolsReleases        = Get-Release $workerToolsProject
    $workerToolsDeployments     = Get-Deployment $workerToolsProject
    $promotionCandidates        = Select-PromotionCandidates $workerToolsReleases $workerToolsDeployments $targetProjectTestEnvironment $targetProjectProdEnvironment

    # Find the current Dynamic Worker production version
    $dynamicWorkerReleases      = Get-Release $dynamicWorkerProject
    $dynamicWorkerDeployments   = Get-Deployment $dynamicWorkerProject
    $currentProductionDw        = Select-ProductionDynamicWorkerRelease $dynamicWorkerReleases $dynamicWorkerDeployments

    # Figure out cached versions of current prod release from TC parameter

    # Promote whichever candidates are ready

}
