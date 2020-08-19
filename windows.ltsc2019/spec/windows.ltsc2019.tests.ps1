$pesterModules = @( Get-Module -Name "Pester" -ErrorAction "SilentlyContinue" );

Write-Host 'Running tests with Pester v'+$($pesterModules[0].Version)

Describe  'installed dependencies' {
    It 'has powershell installed' {
        $PSVersionTable.PSVersion.ToString() | Should Match '5.1.17763'
    }

    It 'has Octopus.Client installed ' {
        $expectedVersion = "8.8.3"
        Test-Path "C:\Program Files\PackageManagement\NuGet\Packages\Octopus.Client.$expectedVersion\lib\net452\Octopus.Client.dll" | Should Be $true
        [Reflection.AssemblyName]::GetAssemblyName("C:\Program Files\PackageManagement\NuGet\Packages\Octopus.Client.$expectedVersion\lib\net452\Octopus.Client.dll").Version.ToString() | Should Match "$expectedVersion.0"
    }

    It 'has dotnet installed' {
        dotnet --version | Should Match '3.1.401'
        $LASTEXITCODE | Should be 0
    }

    It 'has java installed' {
      java -version 2>&1 | Select-String -Pattern '14\.0\.2' | Should BeLike "*14.0.2*"
      $LASTEXITCODE | Should be 0
    }

    It 'has az installed' {
      $output = (& az version) | convertfrom-json
      $output.'azure-cli' | Should Be '2.10.1'
      $LASTEXITCODE | Should be 0
    }

    It 'has aws powershell installed' {
      Get-AWSPowerShellVersion | Should Match '4.0.6'
    }

    It 'has node installed' {
        node --version | Should Match '12.18.3'
        $LASTEXITCODE | Should be 0
    }

    It 'has kubectl installed' {
        kubectl version --client | Should Match '1.18.8'
        $LASTEXITCODE | Should be 0
    }

    It 'has helm installed' {
        helm version | Should Match '3.3.0'
        $LASTEXITCODE | Should be 0
    }

    It 'has terraform installed' {
        terraform version | Should Match '0.13.0'
        $LASTEXITCODE | Should be 0
    }

    It 'has python installed' {
        python --version | Should Match '3.8.5'
        $LASTEXITCODE | Should be 0
    }

    It 'has gcloud installed' {
        gcloud --version | Select-String -Pattern "305.0.0" | Should BeLike "*305.0.0*"
        $LASTEXITCODE | Should be 0
    }

    It 'has octo installed' {
        octo --version | Should Match '7.4.1'
        $LASTEXITCODE | Should be 0
    }

    It 'has eksctl installed' {
        eksctl version | Should Match '0.25.0'
        $LASTEXITCODE | Should be 0
    }

    It 'has 7zip installed' {
        $output = (& "C:\Program Files\7-Zip\7z.exe" --help) -join "`n"
        $output | Should Match '7-Zip 19.00'
        $LASTEXITCODE | Should be 0
    }

    It 'should have installed powershell core' {
        $output = & pwsh --version
        $LASTEXITCODE | Should be 0
        $output | Should Match '^PowerShell 7\.0\.3*'
    }
}
