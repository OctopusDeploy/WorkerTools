BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath "enthusiastic-promotor.ps1")
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
}
