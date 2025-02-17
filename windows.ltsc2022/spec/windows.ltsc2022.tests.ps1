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
        $expectedVersion = "14.3.1916"
        Test-Path "C:\Program Files\PackageManagement\NuGet\Packages\Octopus.Client.$expectedVersion\lib\net462\Octopus.Client.dll" | Should -Be $true
        [Reflection.AssemblyName]::GetAssemblyName("C:\Program Files\PackageManagement\NuGet\Packages\Octopus.Client.$expectedVersion\lib\net462\Octopus.Client.dll").Version.ToString() | Should -Match "$expectedVersion.0"
    }

    It 'has dotnet installed' {
        dotnet --version | Should -Match '8.0.\d+'
        $LASTEXITCODE | Should -be 0
    }

    It 'has java installed' {
        java -version 2>&1 | Select-String -Pattern '21\.0\.2' | Should -BeLike "*21.0.2*"
        $LASTEXITCODE | Should -be 0
    }

    It 'has az installed' {
      $output = (& az version) | convertfrom-json
      $output.'azure-cli' | Should -Be '2.67.0'
      $LASTEXITCODE | Should -be 0
    }
    
    It 'has az powershell module installed' {
        (Get-Module Az -ListAvailable).Version.ToString() | should -be '13.0.0'
    }

    It 'has aws cli installed' {
      aws --version 2>&1 | Should -Match '2.22.31'
    }

    It 'has aws powershell installed' {
      Import-Module AWSPowerShell.NetCore
      Get-AWSPowerShellVersion | Should -Match '4.1.732'
    }
    
    # There is no version command for aws-iam-authenticator, so we just check for the installed version.
    It 'has aws-iam-authenticator installed' {
        Test-Path 'C:\ProgramData\chocolatey\bin\aws-iam-authenticator.exe' | should -be $true
    }

    It 'has node installed' {
        node --version | Should -Match '22.11.0'
        $LASTEXITCODE | Should -be 0
    }

    It 'has kubectl installed' {
        kubectl version --client | Select-String -Pattern "1.32.0" | Should -BeLike "Client Version: v1.32.0"
        $LASTEXITCODE | Should -be 0
    }

    It 'has kubelogin installed' {
        kubelogin --version | Select-Object -First  1 -Skip 1 | Should -match 'v0.1.6'
        $LASTEXITCODE | Should -be 0
    }

    It 'has helm installed' {
        helm version | Should -Match '3.16.4'
        $LASTEXITCODE | Should -be 0
    }

    # If the terraform version is not the latest, then `terraform version` returns multiple lines and a non-zero return code
    It 'has terraform installed' {
        terraform version | Select-Object -First 1 | Should -Match '1.10.4'
    }

    It 'has python installed' {
        python --version | Should -Match '3.13.1'
        $LASTEXITCODE | Should -be 0
    }

    It 'has gcloud installed' {
        gcloud --version | Select-String -Pattern "505.0.0" | Should -BeLike "Google Cloud SDK 505.0.0"
        $LASTEXITCODE | Should -be 0
    }
    
    It 'has gke-gcloud-auth-plugin installed' {
        gcloud --version | Select-String -Pattern "0.5.9" | Should -BeLike "gke-gcloud-auth-plugin 0.5.9"
        $LASTEXITCODE | Should -be 0
    }

    It 'has octopus cli installed' {
        octopus version | Should -Match '2.14.0'
        $LASTEXITCODE | Should -be 0
    }    

    It 'has octo installed' {
        octo --version | Should -Match '9.1.7'
        $LASTEXITCODE | Should -be 0
    }

    It 'has eksctl installed' {
        eksctl version | Should -Match '0.200.0'
        $LASTEXITCODE | Should -be 0
    }

    It 'has 7zip installed' {
        $output = (& "C:\Program Files\7-Zip\7z.exe" --help) -join "`n"
        $output | Should -Match '7-Zip 24.09'
        $LASTEXITCODE | Should -be 0
    }

    It 'should have installed powershell core' {
        $output = & pwsh --version
        $LASTEXITCODE | Should -be 0
        $output | Should -Match '^PowerShell 7\.4\.6*'
    }

    It 'should have installed git' {
        $output = & git --version
        $LASTEXITCODE | Should -be 0
        $output | Should -Match '2.47.1'
    }

    It 'should have installed argo cli' {
        $output = (& argocd version --client) -join "`n"
        $LASTEXITCODE | Should -be 0
        $output | Should -Match '2.13.3'
    }
}
