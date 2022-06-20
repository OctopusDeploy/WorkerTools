BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath "enthusiastic-promotor.ps1")
}

Describe "Get-PromotionCandidates" {
    It "with no parameters returns nothing" {
        $result = Get-PromotionCandidates
        $result.Count | Should -Be 0
    }
}
