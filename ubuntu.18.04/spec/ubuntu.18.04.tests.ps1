$ErrorActionPreference = "Continue"

Install-Module Pester -Force
Import-Module Pester

$pesterModules = @( Get-Module -Name "Pester");
Write-Host 'Running tests with Pester v'+$($pesterModules[0].Version)

Describe  'installed dependencies' {
    It 'has Octopus.Client installed ' {
        $expectedVersion = "8.8.3"
        [Reflection.AssemblyName]::GetAssemblyName("/Octopus.Client.dll").Version.ToString() | Should -match "$expectedVersion.0"
    }

    It 'has dotnet installed' {
        dotnet --version | Should -match '3.1.401'
        $LASTEXITCODE | Should -be 0
    }

    It 'has java installed' {
        java --version | Should -beLike "*11.0.9*"
        $LASTEXITCODE | Should -be 0
    }

    It 'has az installed' {
      $output = (& az version) | convertfrom-json
      $output.'azure-cli' | Should -be '2.14.0'
      $LASTEXITCODE | Should -be 0
    }

    it 'has az powershell module installed' {
        (Get-Module Az -ListAvailable).Version.ToString() | should -be '4.5.0'
    }

    It 'has aws cli installed' {
      aws --version 2>&1 | Should -match '2.0.60'
    }

    It 'has node installed' {
        node --version | Should -match '14.15.1'
        $LASTEXITCODE | Should -be 0
    }

    It 'has kubectl installed' {
        kubectl version --client | Should -match '1.18.8'
        $LASTEXITCODE | Should -be 0
    }

    It 'has helm installed' {
        helm version | Should -match '3.3.0'
        $LASTEXITCODE | Should -be 0
    }

    # If the terraform version is not the latest, then `terraform version` returns multiple lines and a non-zero return code
    It 'has terraform installed' {
        terraform version | Select-Object -First 1 | Should -match '0.13.7'
    }

    It 'has python3 installed' {
        python3 --version | Should -match '3.6.9'
        $LASTEXITCODE | Should -be 0
    }

    It 'has python2 installed' {
        # python 2 prints it's version to stderr, for some reason
        python --version 2>&1 | Should -match 'Python 2.7.17'
        $LASTEXITCODE | Should -be 0
    }

    It 'has gcloud installed' {
        gcloud --version | Select-String -Pattern "2020" | Should -beLike "*2020*"
        $LASTEXITCODE | Should -be 0
    }

    It 'has octo installed' {
        octo --version | Should -match '7.4.1'
        $LASTEXITCODE | Should -be 0
    }

    It 'has eksctl installed' {
        eksctl version | Should -match '0.25.0'
        $LASTEXITCODE | Should -be 0
    }

    It 'has ecs-cli installed' {
        ecs-cli --version | Should -match '1.20.0'
        $LASTEXITCODE | Should -be 0
    }

    It 'has mvn installed' {
        mvn --version | out-null
        $LASTEXITCODE | Should -be 0
    }

    It 'has gradle installed' {
        gradle --version | out-null
        $LASTEXITCODE | Should -be 0
    }

    It 'has aws-iam-authenticator installed' {
        aws-iam-authenticator version | Should -match '0.5.1'
        $LASTEXITCODE | Should -be 0
    }

    It 'has istioctl installed' {
        istioctl version | out-null
        $LASTEXITCODE | Should -be 0
    }

    It 'has linkerd installed' {
        linkerd version | out-null
        $LASTEXITCODE | Should -be 0
    }

    It 'has skopeo installed' {
        skopeo --version | out-null
        $LASTEXITCODE | Should -be 0
    }

    It 'has umoci installed' {
        umoci --version | out-null
        $LASTEXITCODE | Should -be 0
    }

    It 'should have installed powershell core' {
        $output = & pwsh --version
        $LASTEXITCODE | Should -be 0
        $output | Should -match '^PowerShell 7\.0\.3*'
    }
}
