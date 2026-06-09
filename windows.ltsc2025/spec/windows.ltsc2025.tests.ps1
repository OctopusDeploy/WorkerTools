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
        choco --version | Should -Match '2.7.2'
        $LASTEXITCODE | Should -be 0
    }

    It 'has Octopus.Client installed ' {
        $expectedVersion = "21.12.2734"
        Test-Path "C:\Program Files\PackageManagement\NuGet\Packages\Octopus.Client.$expectedVersion\lib\net462\Octopus.Client.dll" | Should -Be $true
        [Reflection.AssemblyName]::GetAssemblyName("C:\Program Files\PackageManagement\NuGet\Packages\Octopus.Client.$expectedVersion\lib\net462\Octopus.Client.dll").Version.ToString() | Should -Match "$expectedVersion.0"
    }

    It 'has dotnet installed' {
        dotnet --version | Should -Match '10.0.\d+'
        $LASTEXITCODE | Should -be 0
    }

    It 'has the .NET 8 runtime installed' {
        (dotnet --list-runtimes) | Select-String -Pattern 'Microsoft.NETCore.App 8.0.27' | Should -Not -BeNullOrEmpty
        $LASTEXITCODE | Should -be 0
    }

    It 'has .NET Framework 4.8.1 installed' {
        $release = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full' -Name Release).Release
        $release | Should -BeGreaterOrEqual 533320
    }

    It 'has java installed' {
        java -version 2>&1 | Select-String -Pattern '25' | Should -BeLike "*25*"
        $LASTEXITCODE | Should -be 0
    }

    It 'has az installed' {
      $output = (& az version) | convertfrom-json
      $output.'azure-cli' | Should -Be '2.86.0'
      $LASTEXITCODE | Should -be 0
    }

    It 'has az powershell module installed' {
        (Get-Module Az -ListAvailable).Version.ToString() | should -be '15.6.1'
    }

    It 'has aws cli installed' {
      aws --version 2>&1 | Should -Match '2.34.53'
    }

    It 'has aws powershell installed' {
      Import-Module AWSPowerShell.NetCore
      Get-AWSPowerShellVersion | Should -Match '5.0.218'
    }

    # There is no version command for aws-iam-authenticator, so we just check for the installed version.
    It 'has aws-iam-authenticator installed' {
        Test-Path 'C:\ProgramData\chocolatey\bin\aws-iam-authenticator.exe' | should -be $true
    }

    It 'has node installed' {
        node --version | Should -Match '24.16.0'
        $LASTEXITCODE | Should -be 0
    }

    It 'has kubectl installed' {
        kubectl version --client | Select-String -Pattern "1.36.1" | Should -BeLike "Client Version: v1.36.1"
        $LASTEXITCODE | Should -be 0
    }

    It 'has multiple kubectl versions available' {
        foreach ($v in @('1.32.12', '1.33.8', '1.34.4', '1.35.1', '1.36.1')) {
            Test-Path "C:\kubectl\kubectl-$v.exe" | Should -Be $true
            (& "C:\kubectl\kubectl-$v.exe" version --client) | Select-String -Pattern $v | Should -BeLike "*v$v"
        }
    }

    It 'has kubelogin installed' {
        kubelogin --version | Select-Object -First  1 -Skip 1 | Should -match 'v0.2.17'
        $LASTEXITCODE | Should -be 0
    }

    It 'has helm installed' {
        helm version | Should -Match '3.20.1'
        $LASTEXITCODE | Should -be 0
    }

    # If the terraform version is not the latest, then `terraform version` returns multiple lines and a non-zero return code
    It 'has terraform installed' {
        terraform version | Select-Object -First 1 | Should -Match '1.15.4'
    }

    It 'has python installed' {
        python --version | Should -Match '3.14.5'
        $LASTEXITCODE | Should -be 0
    }

    It 'has pip installed and working' {
        python -m pip --version | Should -Match 'pip 26.1.2'
        $LASTEXITCODE | Should -be 0
    }

    It 'has gcloud installed' {
        gcloud --version | Select-String -Pattern "566.0.0" | Should -BeLike "Google Cloud SDK 566.0.0"
        $LASTEXITCODE | Should -be 0
    }

    # Version follows gcloud SDK bundled plugin; pin loosely to avoid drift.
    It 'has gke-gcloud-auth-plugin installed' {
        gke-gcloud-auth-plugin --version | Select -First 1 | Should -BeLike "Kubernetes v*"
        $LASTEXITCODE | Should -be 0
    }

    It 'has octopus cli installed' {
        octopus version | Should -Match '2.21.1'
        $LASTEXITCODE | Should -be 0
    }

    It 'has octo installed' {
        octo --version | Should -Match '9.1.7'
        $LASTEXITCODE | Should -be 0
    }

    It 'has eksctl installed' {
        eksctl version | Should -Match '0.226.0'
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
        $output | Should -Match '2.54.0'
    }

    It 'should have installed argo cli' {
        $output = (& argocd version --client) -join "`n"
        $LASTEXITCODE | Should -be 0
        $output | Should -Match '3.4.2'
    }

    It 'has nuget cli installed' {
        $output = & nuget help
        $LASTEXITCODE | Should -be 0
        $output | Select-Object -First 1 | Should -Match '7.6.0'
    }
}
