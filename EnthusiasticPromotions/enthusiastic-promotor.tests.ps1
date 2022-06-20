using module .\enthusiastic-promotor.psm1

$stagingEnvironment = "Environments-1"
$prodEnvironment = "Environments-2"

BeforeAll {
    . .\enthusiastic-promotor.ps1 -targetProjectTestEnvironment $stagingEnvironment -targetProjectProdEnvironment $prodEnvironment
}

Describe "Get-PromotionCandidates" {
    It "with no parameters returns nothing" {
        # Act
        $result = Get-PromotionCandidates ([Release[]] @()) ([Deployment[]] @())

        # Assert
        $result.Count | Should -Be 0
    }

    It "with a Release and no Deployments returns nothing" {
        # Arrange
        $releases = [Release[]] @( [Release]::new("Release-1", "Project-1") )
        $deployments = [Deployment[]] @()
        
        # Act
        $result = Get-PromotionCandidates $releases $deployments

        # Assert
        $result.Count | Should -Be 0
    }

    It "with no Releases and a Deployment returns nothing" {
        # Arrange
        $releases = [Release[]] @()
        $deployments = [Deployment[]] @( [Deployment]::new("Deployment-1", "Release-1", "Project-1") )
        
        # Act
        $result = Get-PromotionCandidates $releases $deployments

        # Assert
        $result.Count | Should -Be 0
    }

    It "ignores already promoted Releases" {
        # Arrange
        $releases = [Release[]] @( [Release]::new("Release-1", "Project-1") )
        $deployments = [Deployment[]] @( 
            [Deployment]::new("Deployment-1", "Release-1", $stagingEnvironment)
            [Deployment]::new("Deployment-2", "Release-1", $prodEnvironment)
        )

        # Act
        $result = Get-PromotionCandidates $releases $deployments

        # Assert
        $result.Count | Should -Be 0
    }

    It "includes unpromoted Releases" {
        # Arrange
        $releases = [Release[]] @( 
            [Release]::new("Release-1", "Project-1")
            [Release]::new("Release-2", "Project-1")
        )
        $deployments = [Deployment[]] @( 
            [Deployment]::new("Deployment-1", "Release-1", $stagingEnvironment)
            [Deployment]::new("Deployment-2", "Release-1", $prodEnvironment)

            [Deployment]::new("Deployment-3", "Release-2", $stagingEnvironment)
        )

        # Act
        $result = Get-PromotionCandidates $releases $deployments

        # Assert
        $result.Count | Should -Be 1
        $result[0].ReleaseId | Should -Be "Release-2"
    }

    It "excludes superseded unpromoted Releases" {
        # Arrange
        $releases = [Release[]] @( 
            [Release]::new("Release-1", "Project-1", [DateTime]::Now.AddDays(-10))
            [Release]::new("Release-2", "Project-1", [DateTime]::Now.AddDays(-7))
            [Release]::new("Release-3", "Project-1", [DateTime]::Now.AddDays(-3))
        )
        $deployments = [Deployment[]] @( 
            [Deployment]::new("Deployment-1", "Release-1", $stagingEnvironment)

            [Deployment]::new("Deployment-2", "Release-2", $stagingEnvironment)
            [Deployment]::new("Deployment-3", "Release-2", $prodEnvironment)

            [Deployment]::new("Deployment-4", "Release-3", $stagingEnvironment)
        )

        # Act
        $result = Get-PromotionCandidates $releases $deployments

        # Assert
        $result.Count | Should -Be 1
        $result[0].ReleaseId | Should -Be "Release-3"
    }
}
