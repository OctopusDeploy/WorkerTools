Write-Output "##teamcity[blockOpened name='Pester tests']"

try {
    # Keep Pester in the v5 range
    Install-Module -Name "Pester" -MinimumVersion "5.7.1" -MaximumVersion "5.99.99" -Force

    Import-Module -Name "Pester" -MinimumVersion "5.7.1"

    Set-Location /app/spec

    Write-Output "Running Pester Tests"
    $configuration = [PesterConfiguration]::Default
    $configuration.TestResult.Enabled = $true
    $configuration.TestResult.OutputPath = '/app/spec/PesterTestResults.xml'
    $configuration.TestResult.OutputFormat = 'NUnitXml'
    $configuration.Run.PassThru = $true
    $configuration.Output.Verbosity = "Detailed"

    Invoke-Pester -configuration $configuration
} catch {
    exit 1
}
Write-Output "##teamcity[blockClosed name='Pester tests']"
