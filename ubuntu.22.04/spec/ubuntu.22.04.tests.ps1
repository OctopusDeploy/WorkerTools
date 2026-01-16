$ErrorActionPreference = "Continue"

$pesterModules = @( Get-Module -Name "Pester");
Write-Host 'Running tests with Pester v'+$($pesterModules[0].Version)

Describe  'installed dependencies' {
    It 'has Octopus.Client installed ' {
        $expectedVersion = "20.3.2503"
        [Reflection.AssemblyName]::GetAssemblyName("/Octopus.Client.dll").Version.ToString() | Should -match "$expectedVersion.0"
    }

    It 'has dotnet installed' {
        dotnet --version | Should -match '8.0.\d+'
        $LASTEXITCODE | Should -be 0
    }

    It 'has java installed' {
        java --version | Should -beLike "* 25.0.*"
        $LASTEXITCODE | Should -be 0
    }

    It 'has aws powershell module installed' {
        (Get-Module AWSPowerShell.NetCore -ListAvailable).Version.ToString() | should -be '5.0.128'
    }

    It 'has az installed' {
      $output = (& az version) | convertfrom-json
      $output.'azure-cli' | Should -be '2.80.0'
      $LASTEXITCODE | Should -be 0
    }

    It 'has az powershell module installed' {
        (Get-Module Az -ListAvailable).Version.ToString() | should -be '15.1.0'
    }

    It 'has aws cli installed' {
      aws --version 2>&1 | Should -match '2.32.28'
    }

    It 'has node installed' {
        node --version | Should -match '24.\d+.\d+'
        $LASTEXITCODE | Should -be 0
    }

    It 'has kubectl installed' {
        kubectl version --client | Select-Object -First 1 | Should -match '1.35.\d+'
        $LASTEXITCODE | Should -be 0
    }

    It 'has kubelogin installed' {
        kubelogin --version | Select-Object -First  1 -Skip 1 | Should -match 'v0.2.13'
        $LASTEXITCODE | Should -be 0
    }

    It 'has helm installed' {
        helm version | Should -match '3.19.0'
        $LASTEXITCODE | Should -be 0
    }

    # If the terraform version is not the latest, then `terraform version` returns multiple lines and a non-zero return code
    It 'has terraform installed' {
        terraform version | Select-Object -First 1 | Should -match '1.14.3'
    }

    It 'has python3 installed' {
        python3 --version | Should -match '3.10.12'
        $LASTEXITCODE | Should -be 0
    }

    It 'has python2 installed' {
        # python 2 prints it's version to stderr, for some reason
        python --version 2>&1 | Should -match 'Python 2.7.18'
        $LASTEXITCODE | Should -be 0
    }

    It 'has gcloud installed' {
        gcloud --version | Select -First 1 | Should -be 'Google Cloud SDK 550.0.0'
        $LASTEXITCODE | Should -be 0
    }
    
    It 'has gke-gcloud-auth-plugin installed' {
        #We use belike here as the hash after the 'alpha+' changes and isn't that important
        gke-gcloud-auth-plugin --version | Select -First 1 | Should -beLike 'Kubernetes v1.30.0+*'
        $LASTEXITCODE | Should -be 0
    }

    It 'has octopus cli installed' {
        octopus version | Should -match '2.20.1'
        $LASTEXITCODE | Should -be 0
    }     

    It 'has octo installed' {
        octo --version | Should -match '9.1.7'
        $LASTEXITCODE | Should -be 0
    }

    It 'has eksctl installed' {
        eksctl version | Should -match '0.221.0'
        $LASTEXITCODE | Should -be 0
    }

    It 'has ecs-cli installed' {
        ecs-cli --version | Should -match '1.21.0'
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
        istioctl version --remote=false | out-null
        $LASTEXITCODE | Should -be 0
    }

    It 'has linkerd installed' {
        linkerd version --client | out-null
        $LASTEXITCODE | Should -be 0
    }

    It 'should have installed powershell core' {
        $output = & pwsh --version
        $LASTEXITCODE | Should -be 0
        $output | Should -match '^PowerShell 7\.5\.4*'
    }

    It 'should have installed argo cli' {
        $output = (& argocd version --client) -join "`n"
        $LASTEXITCODE | Should -be 0
        $output | Should -Match '3.2.3'
    }
}
