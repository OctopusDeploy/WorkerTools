$pesterModules = @( Get-Module -Name "Pester" -ErrorAction "SilentlyContinue" );

Write-Host 'Running tests with Pester v'+$($pesterModules[0].Version)

$PowershellVersion = '5.1.17763';

Describe  'installed dependencies' {
    It 'has powershell $PowershellVersion is installed' {
        $PSVersionTable.PSVersion.ToString() | Should Match $PowershellVersion
    }

    It 'has Octopus.Client is installed ' {
      [Reflection.AssemblyName]::GetAssemblyName("C:\Program Files\PackageManagement\NuGet\Packages\Octopus.Client.8.4.2\lib\net452\Octopus.Client.dll").Version.ToString() | Should Match '8.4.2.0'
    }

    It 'has dotnet is installed' {
        dotnet --version | Should Match '3.1.201'
    }

    It 'has java is installed' {
      java --version | Select-String -Pattern '14\+36\-1461' | Should BeLike "*14+36-1461*"
    }

    It 'has az is installed' {
      az --version | Select-String -Pattern '2.4.0' | Should Match '2.4.0'
    }

    It 'has aws is installed' {
      Get-AWSPowerShellVersion | Should Match '4.0.5'
    }

    It 'has node is installed' {
        node --version | Should Match '12.16.2'
    }

    It 'has kubectl is installed' {
        kubectl version --client | Should Match '1.18.0'
    }

    It 'has helm is installed' {
        helm version | Should Match '3.1.2'
    }

    It 'has terraform is installed' {
        terraform version | Should Match '0.12.24'
    }

    It 'has python is installed' {
        python --version | Should Match '3.8.2'
    }

    It 'has gcloud is installed' {
      gcloud --version | Select-String -Pattern "289.0.0" | Should BeLike "*289.0.0*"
    }

    It 'has octo is installed' {
        octo --version | Should Match '7.3.4'
    }

    It 'has eksctl is installed' {
        eksctl version | Should Match '0.23.0'
    }
}
