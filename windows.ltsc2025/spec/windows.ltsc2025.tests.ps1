$ErrorActionPreference = "Continue"

$pesterModules = @( Get-Module -Name "Pester");
Write-Host 'Running tests with Pester v'+$($pesterModules[0].Version)

Describe  'installed dependencies' {
    It 'has powershell installed' {
        $output = & powershell -command "`$PSVersionTable.PSVersion.ToString()"
        $LASTEXITCODE | Should -be 0
        $output | Should -Match '^5\.1\.'
    }

    It 'has chocolatey installed' {
        [string](& choco --version) | Should -Match '2.7.2'
        $LASTEXITCODE | Should -be 0
    }

    It 'has Octopus.Client installed ' {
        $expectedVersion = "21.12.2734"
        Test-Path "C:\Program Files\PackageManagement\NuGet\Packages\Octopus.Client.$expectedVersion\lib\net462\Octopus.Client.dll" | Should -Be $true
        [Reflection.AssemblyName]::GetAssemblyName("C:\Program Files\PackageManagement\NuGet\Packages\Octopus.Client.$expectedVersion\lib\net462\Octopus.Client.dll").Version.ToString() | Should -Match "$expectedVersion.0"
    }

    It 'has dotnet installed' {
        [string](& dotnet --version) | Should -Match '10.0.\d+'
        $LASTEXITCODE | Should -be 0
    }

    It 'has the .NET 8 runtime installed' {
        [string](& dotnet --list-runtimes) | Should -Match 'Microsoft.NETCore.App 8.0.27'
        $LASTEXITCODE | Should -be 0
    }

    It 'has .NET Framework 4.8.1 installed' {
        $release = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full' -Name Release).Release
        $release | Should -BeGreaterOrEqual 533320
    }

    It 'has java installed' {
        $output = & java -version 2>&1
        [string]$output | Should -Match '25'
        $LASTEXITCODE | Should -be 0
    }

    It 'has az installed' {
      $output = (& az version) | convertfrom-json
      $output.'azure-cli' | Should -Be '2.88.0'
      $LASTEXITCODE | Should -be 0
    }

    It 'has az powershell module installed' {
        (Get-Module Az -ListAvailable).Version.ToString() | Should -Be '15.6.1'
    }

    It 'has aws cli installed' {
        $output = & aws --version 2>&1
        [string]$output | Should -Match '2.34.53'
    }

    It 'has aws powershell installed' {
      Import-Module AWSPowerShell.NetCore
      [string](& Get-AWSPowerShellVersion) | Should -Match '5.0.218'
    }

    It 'has aws-iam-authenticator installed' {
        Test-Path 'C:\ProgramData\chocolatey\bin\aws-iam-authenticator.exe' | Should -Be $true
    }

    It 'has node installed' {
        [string](& node --version) | Should -Match '24.16.0'
        $LASTEXITCODE | Should -be 0
    }

    It 'has kubectl installed' {
        $output = & kubectl version --client
        [string]$output | Should -Match '1.36.1'
        $LASTEXITCODE | Should -be 0
    }

    It 'has multiple kubectl versions available' {
        foreach ($v in @('1.32.12', '1.33.8', '1.34.4', '1.35.1', '1.36.1')) {
            Test-Path "C:\kubectl\kubectl-$v.exe" | Should -Be $true
            [string](& "C:\kubectl\kubectl-$v.exe" version --client) | Should -Match "v$v"
        }
    }

    It 'has kubelogin installed' {
        $output = & kubelogin --version
        [string]$output | Should -Match 'v0.2.18'
        $LASTEXITCODE | Should -be 0
    }

    It 'has helm installed' {
        [string](& helm version) | Should -Match '3.21.3'
        $LASTEXITCODE | Should -be 0
    }

    It 'has terraform installed' {
        $output = & terraform version
        [string]$output | Should -Match '1.15.8'
    }

    It 'has python installed' {
        [string](& python --version) | Should -Match '3.14.5'
        $LASTEXITCODE | Should -be 0
    }

    # There is a quirk in the way Pester handles pip's version output so cast to string
    It 'has pip installed and working' {
        $output = & pip --version
        [string]$output | Should -Match 'pip 26.1.2'
        $LASTEXITCODE | Should -be 0
    }

    It 'has gcloud installed' {
        $output = & gcloud --version
        [string]$output | Should -Match '566.0.0'
        $LASTEXITCODE | Should -be 0
    }

    It 'has gke-gcloud-auth-plugin installed' {
        $output = & gke-gcloud-auth-plugin --version
        [string]$output | Should -Match 'Kubernetes v'
        $LASTEXITCODE | Should -be 0
    }

    It 'has octopus cli installed' {
        [string](& octopus version) | Should -Match '2.21.1'
        $LASTEXITCODE | Should -be 0
    }

    It 'has octo installed' {
        [string](& octo --version) | Should -Match '9.1.7'
        $LASTEXITCODE | Should -be 0
    }

    It 'has eksctl installed' {
        [string](& eksctl version) | Should -Match '0.226.0'
        $LASTEXITCODE | Should -be 0
    }

    It 'has 7zip installed' {
        $output = (& "C:\Program Files\7-Zip\7z.exe" --help) -join "`n"
        $output | Should -Match '7-Zip 26.00'
        $LASTEXITCODE | Should -be 0
    }

    It 'should have installed powershell core' {
        $output = & pwsh --version
        $LASTEXITCODE | Should -be 0
        $output | Should -Match '^PowerShell 7\.6\.1*'
    }

    It 'should have installed git' {
        $output = & git --version
        $LASTEXITCODE | Should -be 0
        [string]$output | Should -Match '2.54.0'
    }

    It 'should have installed argo cli' {
        $output = (& argocd version --client) -join "`n"
        $LASTEXITCODE | Should -be 0
        $output | Should -Match '3.4.2'
    }

    It 'has nuget cli installed' {
        $output = & nuget help
        $LASTEXITCODE | Should -be 0
        [string]($output | Select-Object -First 1) | Should -Match '7.6.0'
    }
}
