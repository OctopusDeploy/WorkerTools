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
        dotnet --version | Should -match '6.0.\d+'
        $LASTEXITCODE | Should -be 0
    }

    It 'has java installed' {
        java --version | Should -beLike "*11.0.17*"
        $LASTEXITCODE | Should -be 0
    }

    It 'has aws powershell module installed' {
        (Get-Module AWSPowerShell.NetCore -ListAvailable).Version.ToString() | should -be '4.1.2.0'
    }

    It 'has az installed' {
      $output = (& az version) | convertfrom-json
      $output.'azure-cli' | Should -be '2.44.1'
      $LASTEXITCODE | Should -be 0
    }

    It 'has az powershell module installed' {
        (Get-Module Az -ListAvailable).Version.ToString() | should -be '4.5.0'
    }

    It 'has aws cli installed' {
      aws --version 2>&1 | Should -match '2.0.60'
    }

    It 'has node installed' {
        node --version | Should -match '14.\d+.\d+'
        $LASTEXITCODE | Should -be 0
    }

    It 'has kubectl installed' {
        kubectl version --client | Should -match '1.18.8'
        $LASTEXITCODE | Should -be 0
    }

    It 'has helm installed' {
        helm version | Should -match '3.7.1'
        $LASTEXITCODE | Should -be 0
    }

    # If the terraform version is not the latest, then `terraform version` returns multiple lines and a non-zero return code
    It 'has terraform installed' {
        terraform version | Select-Object -First 1 | Should -match '1.1.3'
    }

    It 'has python3 installed' {
        python3 --version | Should -match '3.10.6'
        $LASTEXITCODE | Should -be 0
    }

    It 'has python2 installed' {
        # python 2 prints it's version to stderr, for some reason
        python --version 2>&1 | Should -match 'Python 2.7.18'
        $LASTEXITCODE | Should -be 0
    }

    It 'has gcloud installed' {
        gcloud --version | Select -First 1 | Should -be 'Google Cloud SDK 412.0.0'
        $LASTEXITCODE | Should -be 0
    }
    
    It 'has gke-gcloud-auth-plugin installed' {
        gke-gcloud-auth-plugin --version | Select -First 1 | Should -be 'Kubernetes v1.25.2-alpha+ae91c1fc0c443c464a4c878ffa2a4544483c6d1f'
        $LASTEXITCODE | Should -be 0
    }

    It 'has octo installed' {
        octo --version | Should -match '9.1.7'
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
        aws-iam-authenticator version | out-null
        $LASTEXITCODE | Should -be 0
    }

    It 'has istioctl installed' {
        istioctl version | out-null
        $LASTEXITCODE | Should -be 0
    }

    It 'has linkerd installed' {
        linkerd version --client | out-null
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
        $output | Should -match '^PowerShell 7\.2\.7*'
    }
}
