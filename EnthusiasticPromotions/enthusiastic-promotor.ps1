[CmdletBinding()]
param (
    [Parameter()][string] $dynamicWorkerInstanceApiKey,
    [Parameter()][string] $dynamicWorkerInstanceUrl,
    [Parameter()][string] $dynamicWorkerSpaceId,
    [Parameter()][string] $dynamicWorkerProjectId,
    [Parameter()][string] $dynamicWorkerProdEnvironmentId,

    [Parameter()][string] $targetInstanceApiKey,
    [Parameter()][string] $targetInstanceUrl,
    [Parameter()][string] $targetSpaceId,  
    [Parameter()][string] $targetProjectId,
    [Parameter()][string] $targetProjectStagingEnvironmentId,
    [Parameter()][string] $targetProjectProdEnvironmentId,

    [Parameter()][string] $teamCityToken,
    [Parameter()][string] $teamCityUrl,
    [Parameter()][string] $teamCityProjectName,

    [Parameter()][string] $osSuffix,
    [Parameter()][switch] $dryRun = $false
)

$dynamicWorkerProductionTenantIds = @(
    "Tenants-8286"
    "Tenants-8287"
    "Tenants-8288"
)

function Get-FromApi($url, $headers, $formatter) {
    Write-Verbose "Getting response from $url"
    $result = Invoke-RestMethod -Uri "$url" -Headers $headers -TimeoutSec 60 -RetryIntervalSec 10 -MaximumRetryCount 2
    Write-Debug "--------------------------------------------------------"
    Write-Debug "response:"
    Write-Debug "--------------------------------------------------------"
    Write-Debug $($formatter.Invoke($result))
    Write-Debug "--------------------------------------------------------"
    return $result
}

function Get-FromOctopusApi($url, $apiKey) {
    Get-FromApi $url @{ "X-Octopus-ApiKey" = $apiKey } { Param($result) $result | ConvertTo-Json -depth 10 }
}

function Get-FromTeamCityApi($url, $token) {
    Get-FromApi $url @{ "Authorization" = "Bearer $teamCityToken" } { Param($result) $result.outerXml }
}

function Get-Releases($octopusProject) {
    $releasesResponse = Get-FromOctopusApi "$($octopusProject.BaseUri)/api/$($octopusProject.SpaceId)/projects/$($octopusProject.ProjectId)/releases" $octopusProject.ApiKey
    $releasesResponse.Items | Foreach-Object {
        @{
            ReleaseId = $_.Id
            ProjectId = $_.ProjectId
            Version = $_.Version
            Created = $_.Assembled
        }
    }
}

function Get-Deployments($octopusProject) {
    $deploymentsResponse = Get-FromOctopusApi "$($octopusProject.BaseUri)/api/$($octopusProject.SpaceId)/deployments?projects=$($octopusProject.ProjectId)&taskState=Success" $octopusProject.ApiKey
    $deploymentsResponse.Items | Foreach-Object {
        @{
            DeploymentId = $_.Id
            ReleaseId = $_.ReleaseId
            EnvironmentId = $_.EnvironmentId
            TaskId = $_.TaskId
        }
    }
}

function Get-ReleaseVersion($octopusProject, $releaseId) {
    $releaseDetailsResponse = Get-FromOctopusApi "$($octopusProject.BaseUri)/api/$($octopusProject.SpaceId)/releases/$releaseId" $octopusProject.ApiKey
    $releaseDetailsResponse.Version
}

function Get-ProductionDynamicWorkerReleaseIds($dynamicWorkerProductionTenantIds) {
    $deployments = @();
    foreach ($tenantId in $dynamicWorkerProductionTenantIds) {
        $productionDynamicWorkerDeploymentsResponse = Get-FromOctopusApi "$dynamicWorkerInstanceUrl/api/$dynamicWorkerSpaceId/deployments?projects=$dynamicWorkerProjectId&environments=$dynamicWorkerProdEnvironmentId&tenants=$tenantId&taskState=Success" $dynamicWorkerInstanceApiKey
        $deployment = $productionDynamicWorkerDeploymentsResponse.Items | Sort-Object -Property "Created" -Descending | Select-Object -First 1
        $deployments += $deployment
    }
    $deployments | Select-Object -ExpandProperty ReleaseId
}

function Get-DynamicWorkerBuildId($releaseId) {
    $buildNumber = Get-ReleaseVersion $dynamicWorkerProject $releaseId
    $buildInformationResponse = Get-FromTeamCityApi "$teamCityUrl/app/rest/builds?locator=buildType:$teamCityProjectName,number:$buildNumber"
    $buildInformationResponse | Select-Xml -XPath "/builds/build" | ForEach-Object { $_.Node.id } | Select-Object -First 1
}

function Get-CachedWorkerToolsVersions($releaseId) {
    $buildId = Get-DynamicWorkerBuildId $releaseId
    $buildParametersResponse = Get-FromTeamCityApi "$teamCityUrl/app/rest/builds/$buildId/resulting-properties"
    $cachedWorkerToolsVersionsParameter = $buildParametersResponse `
        | Select-Xml -XPath "/properties/property" `
        | Where-Object { $_.Node.name -eq "CachedWorkerToolsVersions" } `
        | Select-Object -First 1 
    $cachedWorkerToolsVersionsValue = $cachedWorkerToolsVersionsParameter.Node.value
    $cachedWorkerToolsVersions = $cachedWorkerToolsVersionsValue -split "," | Select-Object -Unique
    Write-Verbose "Cached worker tools versions for Dynamic Worker release $($releaseId):"
    $cachedWorkerToolsVersions | ForEach-Object { Write-Verbose " - $_" }
    $cachedWorkerToolsVersions
}

function Select-PromotionCandidates($workerToolReleases, $workerToolDeployments, $stagingEnvironmentId, $prodEnvironmentId) {
    if ($workerToolReleases.Count -eq 0 -or $workerToolDeployments.Count -eq 0) {
        return @()
    }

    $chronologicalReleases = $workerToolReleases `
        | Sort-Object -Property "Created", "ReleaseId" -PipelineVariable Release `
        | Foreach-Object { 
            @{ 
                Release = $Release; 
                Deployments = ($workerToolDeployments | Where-Object { $_.ReleaseId -eq $Release.ReleaseId }) 
            } 
        }

    $candidateReleases = @()
    foreach ($release in $chronologicalReleases) {
        $deployedToEnvironments = $workerToolDeployments | Where-Object { $_.ReleaseId -eq $release.Release.ReleaseId } | Select-Object -ExpandProperty EnvironmentId
        if ($deployedToEnvironments -contains $stagingEnvironmentId) {
            if ($deployedToEnvironments -contains $prodEnvironmentId) {
                foreach ($supersededCandidate in $candidateReleases) {
                    Write-Verbose "Ignoring $($supersededCandidate.Version) because it is superseded by a fully promoted release: $($release.Release.Version)"
                }
                Write-Verbose "Ignoring $($release.Release.Version) because it has been fully promoted"

                $candidateReleases = @()
            } else {
                $candidateReleases += $release.Release
            }
        } else {
            Write-Verbose "Ignoring $($release.Release.Version) because it has not been successfully deployed to Staging"
        }
    }

    $candidateReleases
}

function Select-CommonCachedVersions($cachedVersionLists) {
    if ($cachedVersionLists.Count -eq 0) {
        return @()
    }

    $cachedVersions = $cachedVersionLists[0];
    foreach ($versionList in $cachedVersionLists) {
        $cachedVersions = $versionList | Where-Object { $cachedVersions -contains $_ }
    }

    $cachedVersions | Select-Object -Unique
}

function Select-CachedCandidates($promotionCandidates, $cachedWorkerToolsVersions, $osSuffix) {
    $promotionCandidates | Where-Object { "$($_.version)-$osSuffix" -in $cachedWorkerToolsVersions }
}

function New-Promotion($release) {
    & octo deploy-release `
        --deployTo $targetProjectProdEnvironmentId `
        --version $release.Version `
        --project $targetProjectId `
        --apiKey $targetInstanceApiKey `
        --server "$targetInstanceUrl" `
        --space $targetSpaceId
}

function Invoke-Promotion() {
    Write-Host "Finding promotion candidates..."

    $workerToolsReleases = Get-Releases $workerToolsProject
    $workerToolsDeployments = Get-Deployments $workerToolsProject
    $promotionCandidates = Select-PromotionCandidates $workerToolsReleases $workerToolsDeployments $targetProjectStagingEnvironmentId $targetProjectProdEnvironmentId

    if ($promotionCandidates.Count -eq 0) {
        Write-Host "No candidates are waiting for promotion"
        exit 0
    }

    Write-Host "Candidates for promotion:"
    $promotionCandidates | ForEach-Object { Write-Host " - $($_.Version)" }

    Write-Host "Finding cached Worker Tools versions in production..."

    $cachedWorkerToolsVersionLists =  Get-ProductionDynamicWorkerReleaseIds $dynamicWorkerProject.ProductionTenants `
        | ForEach-Object { , (Get-CachedWorkerToolsVersions $_) } 
    $commonCachedWorkerToolsVersions = Select-CommonCachedVersions $cachedWorkerToolsVersionLists

    if ($commonCachedWorkerToolsVersions.Count -eq 0) {
        Write-Warning "Cannot find Worker Tools version cached in production"
        exit 1
    }

    Write-Host "Cached Worker Tools versions in production:"
    $commonCachedWorkerToolsVersions | ForEach-Object { Write-Host " - $_" }

    Write-Host "Deciding Worker Tools releases to promote..."

    $cachedCandidates = Select-CachedCandidates $promotionCandidates $commonCachedWorkerToolsVersions $osSuffix

    if ($cachedCandidates.Count -eq 0) {
        Write-Host "No candidates are cached in production"
        exit 0
    }

    Write-Host "Worker Tools releases to promote are:"
    $cachedCandidates | ForEach-Object { Write-Host " - $($_.Version)" }

    foreach ($release in $cachedCandidates) {
        if ($dryRun) {
            Write-Host "Skip promoting version $($release.Version) since this is a dry run"
        } else {
            New-Promotion $release
            Write-Host "Promoted release $($release.Version)"
        }
    }
}

function Test-AnyArgsPassed {
    return $dynamicWorkerInstanceApiKey `
    -or $dynamicWorkerInstanceUrl `
    -or $dynamicWorkerSpaceId `
    -or $dynamicWorkerProjectId `
    -or $dynamicWorkerProdEnvironmentId `
    -or $targetInstanceApiKey `
    -or $targetInstanceUrl `
    -or $targetSpaceId `
    -or $targetProjectId `
    -or $targetProjectStagingEnvironmentId `
    -or $targetProjectProdEnvironmentId `
    -or $teamCityToken `
    -or $teamCityUrl `
    -or $teamCityProjectName `
    -or $osSuffix
}

function Test-AllArgsPassed {
    return $dynamicWorkerInstanceApiKey `
    -and $dynamicWorkerInstanceUrl `
    -and $dynamicWorkerSpaceId `
    -and $dynamicWorkerProjectId `
    -and $dynamicWorkerProdEnvironmentId `
    -and $targetInstanceApiKey `
    -and $targetInstanceUrl `
    -and $targetSpaceId `
    -and $targetProjectId `
    -and $targetProjectStagingEnvironmentId `
    -and $targetProjectProdEnvironmentId `
    -and $teamCityToken `
    -and $teamCityUrl `
    -and $teamCityProjectName `
    -and $osSuffix
}


if (Test-Path variable:OctopusParameters) {
    Write-Host "Reading parameters from `$OctopusParameters"

    $dynamicWorkerInstanceApiKey       = $OctopusParameters["DynamicWorkerInstanceApiKey"]
    $dynamicWorkerInstanceUrl          = $OctopusParameters["DynamicWorkerInstanceUrl"]
    $dynamicWorkerSpaceId              = $OctopusParameters["DynamicWorkerSpaceId"]
    $dynamicWorkerProjectId            = $OctopusParameters["DynamicWorkerProjectId"]
    $dynamicWorkerProdEnvironmentId    = $OctopusParameters["DynamicWorkerProdEnvironmentId"]

    $targetInstanceApiKey              = $OctopusParameters["TargetInstanceApiKey"]
    $targetInstanceUrl                 = $OctopusParameters["Octopus.Web.ServerUri"]
    $targetSpaceId                     = $OctopusParameters["Octopus.Space.Id"]
    $targetProjectId                   = $OctopusParameters["Octopus.Project.Id"]
    $targetProjectStagingEnvironmentId = $OctopusParameters["TargetInstanceStagingEnvironmentId"]
    $targetProjectProdEnvironmentId    = $OctopusParameters["TargetInstanceProdEnvironmentId"]

    $teamCityToken                     = $OctopusParameters["TeamCityToken"]
    $teamCityUrl                       = $OctopusParameters["TeamCityUrl"]
    $teamCityProjectName               = $OctopusParameters["TeamCityProjectName"]

    $osSuffix                          = $OctopusParameters["OsSuffix"]
} elseif (Test-AllArgsPassed) {
    Write-Host "Reading parameters from command line args"
} elseif (Test-AnyArgsPassed) {
    Write-Warning "Some command line args have been passed, but some are missing. Please validated the args you are passing!"
    exit 1
}
  
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
    ProductionTenants = $dynamicWorkerProductionTenantIds
}

if (Test-AllArgsPassed) {
    Write-Debug "Running with parameters: "
    Write-Debug "  dynamicWorkerInstanceUrl: $dynamicWorkerInstanceUrl"
    Write-Debug "  dynamicWorkerSpaceId: $dynamicWorkerSpaceId"
    Write-Debug "  dynamicWorkerProjectId: $dynamicWorkerProjectId"
    Write-Debug "  dynamicWorkerProdEnvironmentId: $dynamicWorkerProdEnvironmentId"

    Write-Debug "  targetInstanceUrl: $targetInstanceUrl"
    Write-Debug "  targetSpaceId: $targetSpaceId"
    Write-Debug "  targetProjectId: $targetProjectId"
    Write-Debug "  targetProjectStagingEnvironmentId: $targetProjectStagingEnvironmentId"
    Write-Debug "  targetProjectProdEnvironmentId: $targetProjectProdEnvironmentId"

    Write-Debug "  teamCityUrl: $teamCityUrl"
    Write-Debug "  teamCityProjectName: $teamCityProjectName"

    Write-Debug "  osSuffix: $osSuffix"

    try {
        Invoke-Promotion
    } catch {
        [System.Console]::Error.WriteLine("$($error[0].CategoryInfo.Category): $($error[0].Exception.Message)")
        [System.Console]::Error.WriteLine($error[0].InvocationInfo.PositionMessage)
        [System.Console]::Error.WriteLine($error[0].ScriptStackTrace)
        if ($null -ne $error[0].ErrorDetails) {
            [System.Console]::Error.WriteLine($error[0].ErrorDetails.Message)
        }
        exit 1
    }
}