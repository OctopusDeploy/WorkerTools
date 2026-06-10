$ErrorActionPreference = "Continue"

$pesterModules = @( Get-Module -Name "Pester");
Write-Host 'Running tests with Pester v'+$($pesterModules[0].Version)

Describe  'installed dependencies' {
    It 'has powershell installed' {
        $output = & powershell -command "`$PSVersionTable.PSVersion.ToString()"
        $LASTEXITCODE | Should -be 0
        $output | Should -Match '^5\.1\.'
    }

    It 'has Octopus.Client installed ' {
        $expectedVersion = "20.3.2503"
        Test-Path "C:\Program Files\PackageManagement\NuGet\Packages\Octopus.Client.$expectedVersion\lib\net462\Octopus.Client.dll" | Should -Be $true
        [Reflection.AssemblyName]::GetAssemblyName("C:\Program Files\PackageManagement\NuGet\Packages\Octopus.Client.$expectedVersion\lib\net462\Octopus.Client.dll").Version.ToString() | Should -Match "$expectedVersion.0"
    }

    It 'has dotnet installed' {
        [string](& dotnet --version) | Should -Match '8.0.\d+'
        $LASTEXITCODE | Should -be 0
    }

    It 'has java installed' {
        $output = & java -version 2>&1
        [string]$output | Should -Match '25'
        $LASTEXITCODE | Should -be 0
    }

    It 'has az installed' {
        $output = (& az version) | ConvertFrom-Json
        $output.'azure-cli' | Should -Be '2.81.0'
        $LASTEXITCODE | Should -be 0
    }

    It 'has az powershell module installed' {
        (Get-Module Az -ListAvailable).Version.ToString() | Should -Be '15.1.0'
    }

    It 'has aws cli installed' {
        $output = & aws --version 2>&1
        [string]$output | Should -Match '2.32.28'
    }

    It 'has aws powershell installed' {
        Import-Module AWSPowerShell.NetCore
        [string](& Get-AWSPowerShellVersion) | Should -Match '5.0.128'
    }

    It 'has aws-iam-authenticator installed' {
        Test-Path 'C:\ProgramData\chocolatey\bin\aws-iam-authenticator.exe' | Should -Be $true
    }

    It 'has node installed' {
        [string](& node --version) | Should -Match '24.12.0'
        $LASTEXITCODE | Should -be 0
    }

    It 'has kubectl installed' {
        $output = & kubectl version --client
        [string]$output | Should -Match '1.35.0'
        $LASTEXITCODE | Should -be 0
    }

    It 'has kubelogin installed' {
        $output = & kubelogin --version
        [string]$output | Should -Match 'v0.2.13'
        $LASTEXITCODE | Should -be 0
    }

    It 'has helm installed' {
        [string](& helm version) | Should -Match '3.20.2'
        $LASTEXITCODE | Should -be 0
    }

    It 'has terraform installed' {
        $output = & terraform version
        [string]$output | Should -Match '1.14.3'
    }

    It 'has python installed' {
        [string](& python --version) | Should -Match '3.14.5'
        $LASTEXITCODE | Should -be 0
    }

    It 'has gcloud installed' {
        $output = & gcloud --version
        [string]$output | Should -Match '550.0.0'
        $LASTEXITCODE | Should -be 0
    }

    # Version follows gcloud SDK bundled plugin; pin loosely to avoid drift.
    It 'has gke-gcloud-auth-plugin installed' {
        $output = & gke-gcloud-auth-plugin --version
        [string]$output | Should -Match 'Kubernetes v'
        $LASTEXITCODE | Should -be 0
    }

    It 'has octopus cli installed' {
        [string](& octopus version) | Should -Match '2.20.1'
        $LASTEXITCODE | Should -be 0
    }

    It 'has octo installed' {
        [string](& octo --version) | Should -Match '9.1.7'
        $LASTEXITCODE | Should -be 0
    }

    It 'has eksctl installed' {
        [string](& eksctl version) | Should -Match '0.221.0'
        $LASTEXITCODE | Should -be 0
    }

    It 'has 7zip installed' {
        $output = (& "C:\Program Files\7-Zip\7z.exe" --help) -join "`n"
        $output | Should -Match '7-Zip 25.01'
        $LASTEXITCODE | Should -be 0
    }

    It 'should have installed powershell core' {
        $output = & pwsh --version
        $LASTEXITCODE | Should -be 0
        $output | Should -Match '^PowerShell 7\.5\.4*'
    }

    It 'should have installed git' {
        $output = & git --version
        $LASTEXITCODE | Should -be 0
        [string]$output | Should -Match '2.52.0'
    }

    It 'should have installed argo cli' {
        $output = (& argocd version --client) -join "`n"
        $LASTEXITCODE | Should -be 0
        $output | Should -Match '3.2.3'
    }
}
