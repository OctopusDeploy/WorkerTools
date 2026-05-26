Write-Output "##teamcity[blockOpened name='Pester tests']"

try {
    Install-Module -Name "Pester" -MinimumVersion "5.5.0" -Force

    Import-Module -Name "Pester"

    Write-Ouput "Nothing to see here, it's all fake, just to test the build process"
    
} catch {
    exit 1
}
Write-Output "##teamcity[blockClosed name='Pester tests']"
