BeforeAll {
    . $PSScriptRoot/enthusiastic-promotor.ps1

    $stagingEnvironmentId = "Environments-1"
    $prodEnvironmentId = "Environments-2"

    function New-Release($releaseId, $projectId, $version, $created) { 
        return New-Object PSObject -Property @{ 
            ReleaseId = $releaseId
            ProjectId = $projectId
            Version = $version
            Created = $created
        } 
    }

    function New-Deployment($deploymentId, $releaseId, $environmentId) {
        return New-Object PSObject -Property @{ 
            DeploymentId = $deploymentId
            ReleaseId = $releaseId
            EnvironmentId = $environmentId 
        } 
    }
}

Describe "Select-PromotionCandidates" {
    It "ignores already promoted Releases" {
        # Arrange
        $releases = New-Release "Release-1" "Project-1" "0.0.1"
        $deployments = @( 
            New-Deployment "Deployment-1" "Release-1" $stagingEnvironmentId
            New-Deployment "Deployment-2" "Release-1" $prodEnvironmentId
        )

        # Act
        $result = @(Select-PromotionCandidates $releases $deployments $stagingEnvironmentId $prodEnvironmentId)

        # Assert
        $result.Count | Should -Be 0
    }

    It "includes unpromoted Releases" {
        # Arrange
        $releases = @( 
            New-Release "Release-1" "Project-1" "0.0.1"
            New-Release "Release-2" "Project-1" "0.0.2"
        )
        $deployments = @( 
            New-Deployment "Deployment-1" "Release-1" $stagingEnvironmentId
            New-Deployment "Deployment-2" "Release-1" $prodEnvironmentId
            New-Deployment "Deployment-3" "Release-2" $stagingEnvironmentId
        )

        # Act
        $result = @(Select-PromotionCandidates $releases $deployments $stagingEnvironmentId $prodEnvironmentId)

        # Assert
        $result.Count | Should -Be 1
        $result[0].ReleaseId | Should -Be "Release-2"
    }

    It "excludes superseded unpromoted Releases" {
        # Arrange
        $releases = @( 
            New-Release "Release-1" "Project-1" "0.0.1" [DateTime]::Now.AddDays(-10)
            New-Release "Release-2" "Project-1" "0.0.2" [DateTime]::Now.AddDays(-7)
            New-Release "Release-3" "Project-1" "0.0.3" [DateTime]::Now.AddDays(-3)
        )
        $deployments = @( 
            New-Deployment "Deployment-1" "Release-1" $stagingEnvironmentId

            New-Deployment "Deployment-2" "Release-2" $stagingEnvironmentId
            New-Deployment "Deployment-3" "Release-2" $prodEnvironmentId
            New-Deployment "Deployment-4" "Release-3" $stagingEnvironmentId
        )

        # Act
        $result = @(Select-PromotionCandidates $releases $deployments $stagingEnvironmentId $prodEnvironmentId)

        # Assert
        $result.Count | Should -Be 1
        $result[0].ReleaseId | Should -Be "Release-3"
    }
}

Describe "Select-CommonCachedVersions" {
    It "selects the intersection of cached versions lists" {
        # Arrange
        $cachedVersionLists = @(
            , @("0.0.1-ubuntu.18.04", "0.0.2-ubuntu.18.04")
            , @("0.0.2-ubuntu.18.04", "0.0.3-ubuntu.18.04")
            , @("0.0.2-ubuntu.18.04", "0.0.4-ubuntu.18.04")
        )

        # Act
        $result = @(Select-CommonCachedVersions $cachedVersionLists)

        # Assert
        $result.Count | Should -Be 1
        $result[0] | Should -Be "0.0.2-ubuntu.18.04"
    }
}

Describe "Select-CachedCandidates" {
    It "selects candidates that are cached in production" {
        # Arrange
        $release2 = New-Release "Releases-2" "Projects-1" "0.0.2"
        $release3 = New-Release "Releases-3" "Projects-1" "0.0.3"
        $release4 = New-Release "Releases-4" "Projects-1" "0.0.4"

        $promotionCandidates = @($release2, $release3, $release4)

        $cachedWorkerToolsVersions = @(
            "0.0.1-ubuntu.18.04"
            "0.0.2-ubuntu.18.04"
            "0.0.3-ubuntu.18.04"
        )

        # Act
        $result = Select-CachedCandidates $promotionCandidates $cachedWorkerToolsVersions "ubuntu.18.04"

        # Assert
        $result.Count | Should -Be 2
        $release2 | Should -BeIn $result
        $release3 | Should -BeIn $result
    }
}