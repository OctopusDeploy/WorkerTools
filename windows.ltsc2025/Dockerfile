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
ARG Helm_Version=3.21.3
ARG Java_Jdk_Version=25.0.0.1
ARG Kubectl_Version=1.36.1
ARG Kubectl_Versions=1.32.12,1.33.8,1.34.4,1.35.1,1.36.1
ARG Kubelogin_Version=0.2.18
ARG Node_Version=24.16.0
ARG Nuget_Cli_Version=7.6.0
ARG Octopus_Cli_Legacy_Version=9.1.7
ARG Octopus_Cli_Version=2.21.1
ARG Octopus_Client_Version=21.12.2734
ARG Pip_Version=26.1.2
ARG Powershell_Version=7.6.1
ARG Python_Version=3.14.5
ARG ScriptCs_Version=0.17.1
ARG Terraform_Version=1.15.8

# Install Choco
RUN $ProgressPreference = 'SilentlyContinue'; `
    $Env:chocolateyVersion = $Env:Chocolatey_Version; `
    Set-ExecutionPolicy Bypass -Scope Process -Force; `
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; `
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')); `
    wevtutil sl Microsoft-Windows-PowerShell/Operational /e:false

COPY .\scripts\choco-install.ps1 C:\choco-install.ps1

# Disable .NET CLI telemetry
ENV DOTNET_CLI_TELEMETRY_OPTOUT=1

# Install the .NET 8 runtime alongside the .NET 10 SDK from the base image
RUN Invoke-WebRequest 'https://dotnet.microsoft.com/download/dotnet/scripts/v1/dotnet-install.ps1' -outFile 'dotnet-install.ps1'; `
    .\dotnet-install.ps1 -Version $Env:Dotnet_Runtime_Version -Runtime dotnet -InstallDir 'C:\Program Files\dotnet'; `
    rm dotnet-install.ps1

# Install JDK
RUN C:\choco-install.ps1 openjdk $Env:Java_Jdk_Version -AllowEmptyChecksums; if ($LASTEXITCODE) { exit $LASTEXITCODE }; `
    Remove-Item -Force 'C:\Program Files\OpenJDK\jdk-*\lib\src.zip'

# Install Azure CLI
RUN C:\choco-install.ps1 azure-cli $Env:Azure_Cli_Version

# remove az cli warning - https://github.com/Azure/arm-deploy/issues/173
RUN az config set bicep.use_binary_from_path=false 

# Install the AWS CLI
RUN C:\choco-install.ps1 awscli $Env:Aws_Cli_Version; if ($LASTEXITCODE) { exit $LASTEXITCODE }; `
    Remove-Item -Recurse -Force 'C:\Program Files\Amazon\AWSCLIV2\awscli\examples'

# Install the AWS IAM Authenticator 
RUN C:\choco-install.ps1 aws-iam-authenticator $Env:Aws_Iam_Authenticator_Version

# Install AWS PowerShell modules
# https://docs.aws.amazon.com/powershell/latest/userguide/pstools-getting-set-up-windows.html#ps-installing-awspowershellnetcore
RUN Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force; `
    Install-Module -name AWSPowerShell.NetCore -RequiredVersion $Env:Aws_Powershell_Version -Force; `
    Get-ChildItem (Get-Module -ListAvailable AWSPowerShell.NetCore).ModuleBase -Recurse -Filter *-help.xml | Remove-Item -Force

# Install Azure PowerShell modules
# https://docs.microsoft.com/en-us/powershell/azure/install-az-ps?view=azps-3.6.1
RUN Install-Module -Force -Name Az -AllowClobber -Scope AllUsers -MaximumVersion $Env:Azure_Powershell_Version; `
    Enable-AzureRmAlias -Scope LocalMachine; `
    Get-ChildItem (Get-Module -ListAvailable Az, Az.*).ModuleBase -Recurse -Filter *-help.xml | Remove-Item -Force

# Install NodeJS
RUN C:\choco-install.ps1 nodejs-lts $Env:Node_Version

# Install kubectl
RUN New-Item -ItemType Directory -Path C:\kubectl -Force | Out-Null; `
    foreach ($v in ($Env:Kubectl_Versions -split ',')) { `
        Invoke-WebRequest "https://dl.k8s.io/release/v$v/bin/windows/amd64/kubectl.exe" -OutFile "C:\kubectl\kubectl-$v.exe"; `
    } `
    Copy-Item "C:\kubectl\kubectl-$($Env:Kubectl_Version).exe" C:\Windows\system32\kubectl.exe;

# Install Kubelogin
RUN C:\choco-install.ps1 azure-kubelogin $Env:Kubelogin_Version

# Install helm 3
RUN Invoke-WebRequest "https://get.helm.sh/helm-v${Env:Helm_Version}-windows-amd64.zip" -OutFile helm.zip; `
    Expand-Archive helm.zip -DestinationPath helm; `
    mv helm\windows-amd64\helm.exe C:\Windows\system32\; `
    Remove-Item -Recurse -Force helm, helm.zip

# Install Terraform
RUN C:\choco-install.ps1 terraform $Env:Terraform_Version

# Install python
RUN C:\choco-install.ps1 python3 $Env:Python_Version; if ($LASTEXITCODE) { exit $LASTEXITCODE }; `
    Remove-Item -Recurse -Force C:\Python3*\Doc, C:\Python3*\Lib\test

# Install Pip
RUN python -m pip install --no-cache-dir --upgrade pip==$Env:Pip_Version

# Install 7ZIP because gcloud
RUN C:\choco-install.ps1 7zip $Env:7Zip_Version

# Install gcloud
RUN C:\choco-install.ps1 gcloudsdk $Env:Google_Cloud_Cli_Version

# Install gcloud kubectl auth
RUN gcloud components install gke-gcloud-auth-plugin --quiet; if ($LASTEXITCODE) { exit $LASTEXITCODE }; `
    Get-ChildItem (gcloud info --format='value(installation.sdk_root)') -Recurse -Directory -Filter __pycache__ | Remove-Item -Recurse -Force

# Install ScriptCS
RUN C:\choco-install.ps1 scriptcs $Env:ScriptCs_Version

# Install Octopus CLI
RUN C:\choco-install.ps1 octopus-cli $Env:Octopus_Cli_Version

# Install octo
RUN C:\choco-install.ps1 octopustools $Env:Octopus_Cli_Legacy_Version

# Install Octopus Client
RUN Install-Package Octopus.Client -source https://www.nuget.org/api/v2 -SkipDependencies -Force -RequiredVersion $Env:Octopus_Client_Version
    
# Install eksctl
RUN C:\choco-install.ps1 eksctl $Env:Eks_Cli_Version

# Install NuGet CLI
RUN C:\choco-install.ps1 nuget.commandline $Env:Nuget_Cli_Version

# PowerShell 7 is provided by the .NET SDK base image

# Install Git
RUN C:\choco-install.ps1 git.install $Env:Git_Version; if ($LASTEXITCODE) { exit $LASTEXITCODE }; `
    Remove-Item -Recurse -Force 'C:\Program Files\Git\mingw64\share\doc'

# Install Argo CD
RUN C:\choco-install.ps1 argocd-cli $Env:Argo_Cli_Version

# Update path for new tools
ADD .\scripts\update_path.cmd C:\update_path.cmd
RUN .\update_path.cmd;
