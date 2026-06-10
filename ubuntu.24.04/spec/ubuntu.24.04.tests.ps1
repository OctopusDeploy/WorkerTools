$ErrorActionPreference = "Continue"

$pesterModules = @( Get-Module -Name "Pester");
Write-Host 'Running tests with Pester v'+$($pesterModules[0].Version)

Describe  'installed dependencies' {
    It 'has Octopus.Client installed ' {
        $expectedVersion = "21.6.2652"
        [Reflection.AssemblyName]::GetAssemblyName("/Octopus.Client.dll").Version.ToString() | Should -match "$expectedVersion.0"
    }

    It 'has dotnet installed' {
        $output = & dotnet --version
        [string]$output | Should -Match '10\.0\.\d+'
        $LASTEXITCODE | Should -be 0
    }

    It 'has java installed' {
        $output = & java --version 2>&1
        [string]$output | Should -Match '21\.0\.'
        $LASTEXITCODE | Should -be 0
    }

    It 'has aws powershell module installed' {
        $output = (Get-Module AWSPowerShell.NetCore -ListAvailable).Version.ToString()
        [string]$output | Should -Be '5.0.207'
    }

    It 'has az installed' {
        $output = (& az version) | convertfrom-json
        $output.'azure-cli' | Should -be '2.85.0'
        $LASTEXITCODE | Should -be 0
    }

    It 'has az powershell module installed' {
        $output = (Get-Module Az -ListAvailable).Version.ToString()
        [string]$output | Should -Be '15.5.0'
    }

    It 'has aws cli installed' {
        $output = & aws --version 2>&1
        [string]$output | Should -Match '2\.34\.42'
    }

    It 'has node installed' {
        $output = & node --version
        [string]$output | Should -Match '24\.\d+\.\d+'
        $LASTEXITCODE | Should -be 0
    }

    It 'has kubectl installed' {
        $output = & kubectl version --client
        [string]$output | Should -Match '1\.36\.\d+'
        $LASTEXITCODE | Should -be 0
    }

    It 'has kubelogin installed' {
        $output = & kubelogin --version
        [string]$output | Should -Match 'v0\.2\.17'
        $LASTEXITCODE | Should -be 0
    }

    It 'has helm installed' {
        $output = & helm version
        [string]$output | Should -Match '3\.20\.2'
        $LASTEXITCODE | Should -be 0
    }

    # If the terraform version is not the latest, then `terraform version` returns multiple lines and a non-zero return code
    It 'has terraform installed' {
        $output = & terraform version
        [string]$output | Should -Match '1\.15\.1'
    }

    It 'has python3 installed' {
        $output = & python3 --version
        [string]$output | Should -Match '3\.14\.'
        $LASTEXITCODE | Should -be 0
    }

    It 'has gcloud installed' {
        $output = & gcloud --version
        [string]$output | Should -Match '566\.0\.0'
        $LASTEXITCODE | Should -be 0
    }
    
    It 'has gke-gcloud-auth-plugin installed' {
        $output = & gke-gcloud-auth-plugin --version
        [string]$output | Should -Match 'Kubernetes v'
        $LASTEXITCODE | Should -be 0
    }

    It 'has octopus cli installed' {
        $output = & octopus version
        [string]$output | Should -Match '2\.21\.0'
        $LASTEXITCODE | Should -be 0
    }


    It 'has eksctl installed' {
        $output = & eksctl version
        [string]$output | Should -Match '0\.226\.0'
        $LASTEXITCODE | Should -be 0
    }

    It 'has ecs-cli installed' {
        $output = & ecs-cli --version
        [string]$output | Should -Match '1\.21\.0'
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
        [string]$output | Should -Match '^PowerShell 7\.6\.1'
    }

    It 'should have installed argo cli' {
        $output = (& argocd version --client) -join "`n"
        $LASTEXITCODE | Should -be 0
        [string]$output | Should -Match '3\.3\.9'
    }
}
