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

    It "with one Release deployed to all environments returns nothing" {
        # Arrange
        $releases = [Release[]] @( [Release]::new("Release-1", "Project-1") )
        $deployments = [Deployment[]] @( 
            [Deployment]::new("Deployment-1", "Release-1", $stagingEnvironment)
            [Deployment]::new("Deployment-1", "Release-1", $prodEnvironment)
        )

        # Act
        $result = Get-PromotionCandidates $releases $deployments

        # Assert
        $result.Count | Should -Be 0
    }
}
