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
        $expectedVersion = "11.6.3644"
        Test-Path "C:\Program Files\PackageManagement\NuGet\Packages\Octopus.Client.$expectedVersion\lib\net452\Octopus.Client.dll" | Should -Be $true
        [Reflection.AssemblyName]::GetAssemblyName("C:\Program Files\PackageManagement\NuGet\Packages\Octopus.Client.$expectedVersion\lib\net452\Octopus.Client.dll").Version.ToString() | Should -Match "$expectedVersion.0"
    }

    It 'has dotnet installed' {
        dotnet --version | Should -Match '6.0.\d+'
        $LASTEXITCODE | Should -be 0
    }

    It 'has java installed' {
        java -version 2>&1 | Select-String -Pattern '14\.0\.2' | Should -BeLike "*14.0.2*"
        $LASTEXITCODE | Should -be 0
    }

    It 'has az installed' {
      $output = (& az version) | convertfrom-json
      $output.'azure-cli' | Should -Be '2.44.0'
      $LASTEXITCODE | Should -be 0
    }
    
    It 'has az powershell module installed' {
        (Get-Module Az -ListAvailable).Version.ToString() | should -be '4.5.0'
    }

    It 'has aws cli installed' {
      aws --version 2>&1 | Should -Match '2.0.60'
    }

    It 'has aws powershell installed' {
      Import-Module AWSPowerShell.NetCore
      Get-AWSPowerShellVersion | Should -Match '4.1.2'
    }
    
    # There is no version command for aws-iam-authenticator, so we just check for the installed version.
    It 'has aws-iam-authenticator installed' {
        Test-Path 'C:\ProgramData\chocolatey\bin\aws-iam-authenticator.exe' | should -be $true
    }

    It 'has node installed' {
        node --version | Should -Match '14.17.2'
        $LASTEXITCODE | Should -be 0
    }

    It 'has kubectl installed' {
        kubectl version --client | Should -Match '1.18.8'
        $LASTEXITCODE | Should -be 0
    }

    It 'has helm installed' {
        helm version | Should -Match '3.7.1'
        $LASTEXITCODE | Should -be 0
    }

    # If the terraform version is not the latest, then `terraform version` returns multiple lines and a non-zero return code
    It 'has terraform installed' {
        terraform version | Select-Object -First 1 | Should -Match '1.1.3'
    }

    It 'has python installed' {
        python --version | Should -Match '3.8.5'
        $LASTEXITCODE | Should -be 0
    }

    It 'has gcloud installed' {
        gcloud --version | Select-String -Pattern "412.0.0" | Should -BeLike "Google Cloud SDK 412.0.0"
        $LASTEXITCODE | Should -be 0
    }
    
    It 'has gke-gcloud-auth-plugin installed' {
        gcloud --version | Select-String -Pattern "0.4.0" | Should -BeLike "gke-gcloud-auth-plugin 0.4.0"
        $LASTEXITCODE | Should -be 0
    }

    It 'has octo installed' {
        octo --version | Should -Match '9.1.7'
        $LASTEXITCODE | Should -be 0
    }

    It 'has eksctl installed' {
        eksctl version | Should -Match '0.25.0'
        $LASTEXITCODE | Should -be 0
    }

    It 'has 7zip installed' {
        $output = (& "C:\Program Files\7-Zip\7z.exe" --help) -join "`n"
        $output | Should -Match '7-Zip 19.00'
        $LASTEXITCODE | Should -be 0
    }

    It 'should have installed powershell core' {
        $output = & pwsh --version
        $LASTEXITCODE | Should -be 0
        $output | Should -Match '^PowerShell 7\.2\.7*'
    }
}
