# escape=`

FROM mcr.microsoft.com/dotnet/sdk:10.0.300-windowsservercore-ltsc2025
SHELL ["powershell", "-Command"]

ARG 7Zip_Version=26.0.0
ARG Argo_Cli_Version=3.4.2
ARG Chocolatey_Version=2.7.2
ARG Dotnet_Runtime_Version=8.0.27
ARG Aws_Cli_Version=2.34.53
ARG Aws_Iam_Authenticator_Version=0.7.17
ARG Aws_Powershell_Version=5.0.218
ARG Azure_Cli_Version=2.88.0
ARG Azure_Powershell_Version=15.6.1
ARG Eks_Cli_Version=0.226.0
ARG Git_Version=2.54.0
ARG Google_Cloud_Cli_Version=566.0.0
ARG Helm_Version=3.20.1
ARG Java_Jdk_Version=25.0.0.1
ARG Kubectl_Version=1.36.1
ARG Kubectl_Versions=1.32.12,1.33.8,1.34.4,1.35.1,1.36.1
ARG Kubelogin_Version=0.2.17
ARG Node_Version=24.16.0
ARG Nuget_Cli_Version=7.6.0
ARG Octopus_Cli_Legacy_Version=9.1.7
ARG Octopus_Cli_Version=2.21.1
ARG Octopus_Client_Version=21.12.2734
ARG Pip_Version=26.1.2
ARG Powershell_Version=7.6.1
ARG Python_Version=3.14.5
ARG ScriptCs_Version=0.17.1
ARG Terraform_Version=1.15.4

# Install Choco
RUN $ProgressPreference = 'SilentlyContinue'; `
    $Env:chocolateyVersion = $Env:Chocolatey_Version; `
    Set-ExecutionPolicy Bypass -Scope Process -Force; `
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; `
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Disable .NET CLI telemetry
ENV DOTNET_CLI_TELEMETRY_OPTOUT=1

# Install the .NET 8 runtime alongside the .NET 10 SDK from the base image
RUN Invoke-WebRequest 'https://dotnet.microsoft.com/download/dotnet/scripts/v1/dotnet-install.ps1' -outFile 'dotnet-install.ps1'; `
    .\dotnet-install.ps1 -Version $Env:Dotnet_Runtime_Version -Runtime dotnet -InstallDir 'C:\Program Files\dotnet'; `
    rm dotnet-install.ps1

# Install JDK
RUN choco install openjdk --allow-empty-checksums --y --no-progress --version $Env:Java_Jdk_Version; `
    Import-Module $env:ChocolateyInstall\helpers\chocolateyProfile.psm1; `
    Update-SessionEnvironment

# Install Azure CLI
RUN choco install azure-cli -y --version $Env:Azure_Cli_Version --no-progress

# remove az cli warning - https://github.com/Azure/arm-deploy/issues/173
RUN az config set bicep.use_binary_from_path=false 

# Install the AWS CLI
RUN choco install awscli -y --version $Env:Aws_Cli_Version --no-progress

# Install the AWS IAM Authenticator 
RUN choco install aws-iam-authenticator -y --version $Env:Aws_Iam_Authenticator_Version --no-progress

# Install AWS PowerShell modules
# https://docs.aws.amazon.com/powershell/latest/userguide/pstools-getting-set-up-windows.html#ps-installing-awspowershellnetcore
RUN Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force; `
    Install-Module -name AWSPowerShell.NetCore -RequiredVersion $Env:Aws_Powershell_Version -Force

# Install Azure PowerShell modules
# https://docs.microsoft.com/en-us/powershell/azure/install-az-ps?view=azps-3.6.1
RUN Install-Module -Force -Name Az -AllowClobber -Scope AllUsers -MaximumVersion $Env:Azure_Powershell_Version; `
    Enable-AzureRmAlias -Scope LocalMachine

# Install NodeJS
RUN choco install nodejs-lts -y --version $Env:Node_Version --no-progress

# Install kubectl
RUN New-Item -ItemType Directory -Path C:\kubectl -Force | Out-Null; `
    foreach ($v in ($Env:Kubectl_Versions -split ',')) { `
        Invoke-WebRequest "https://dl.k8s.io/release/v$v/bin/windows/amd64/kubectl.exe" -OutFile "C:\kubectl\kubectl-$v.exe"; `
    } `
    Copy-Item "C:\kubectl\kubectl-$($Env:Kubectl_Version).exe" C:\Windows\system32\kubectl.exe;

# Install Kubelogin
RUN choco install azure-kubelogin --version $Env:Kubelogin_Version --no-progress -y

# Install helm 3
RUN Invoke-WebRequest "https://get.helm.sh/helm-v${Env:Helm_Version}-windows-amd64.zip" -OutFile helm.zip; `
    Expand-Archive helm.zip -DestinationPath helm; `
    mv helm\windows-amd64\helm.exe C:\Windows\system32\; `
    Remove-Item -Recurse -Force helm, helm.zip

# Install Terraform
RUN choco install -y terraform --version $Env:Terraform_Version --no-progress

# Install python
RUN choco install -y python3 --version $Env:Python_Version --no-progress; `
    Import-Module $env:ChocolateyInstall\helpers\chocolateyProfile.psm1; `
    Update-SessionEnvironment

# Install Pip
RUN python -m pip install --upgrade pip==$Env:Pip_Version; `
    Import-Module $env:ChocolateyInstall\helpers\chocolateyProfile.psm1; `
    Update-SessionEnvironment

# Install 7ZIP because gcloud
RUN choco install 7zip -y --version $Env:7Zip_Version --no-progress

# Install gcloud
RUN choco install gcloudsdk -y --version $Env:Google_Cloud_Cli_Version --no-progress

# Install gcloud kubectl auth
RUN gcloud components install gke-gcloud-auth-plugin --quiet

# Install ScriptCS
RUN choco install scriptcs -y --version $Env:ScriptCs_Version --no-progress

# Install Octopus CLI
RUN choco install octopus-cli -y --version $Env:Octopus_Cli_Version --no-progress

# Install octo
RUN choco install octopustools -y --version $Env:Octopus_Cli_Legacy_Version --no-progress

# Install Octopus Client
RUN Install-Package Octopus.Client -source https://www.nuget.org/api/v2 -SkipDependencies -Force -RequiredVersion $Env:Octopus_Client_Version
    
# Install eksctl
RUN choco install eksctl -y --version $Env:Eks_Cli_Version --no-progress

# Install NuGet CLI
RUN choco install nuget.commandline -y --version $Env:Nuget_Cli_Version --no-progress

# PowerShell 7 is provided by the .NET SDK base image

# Install Git
RUN choco install git.install --yes --version $Env:Git_Version --no-progress

# Install Argo CD
RUN choco install argocd-cli --yes --version $Env:Argo_Cli_Version --no-progress

# Update path for new tools
ADD .\scripts\update_path.cmd C:\update_path.cmd
RUN .\update_path.cmd;
