# escape=`

FROM mcr.microsoft.com/dotnet/framework/runtime:4.8.1-20230808-windowsservercore-ltsc2022
SHELL ["powershell", "-Command"]

ARG 7Zip_Version=25.1.0
ARG Argo_Cli_Version=3.2.3
ARG Aws_Cli_Version=2.32.28
ARG Aws_Iam_Authenticator_Version=0.7.10
ARG Aws_Powershell_Version=5.0.128
ARG Azure_Cli_Version=2.81.0
ARG Azure_Powershell_Version=15.1.0
ARG Eks_Cli_Version=0.221.0
ARG Git_Version=2.52.0
ARG Google_Cloud_Cli_Version=550.0.0
ARG Helm_Version=3.19.0
ARG Java_Jdk_Version=25.0.0.1
ARG Kubectl_Version=1.35.0
ARG Kubelogin_Version=0.2.13
ARG Node_Version=24.12.0
ARG Octopus_Cli_Legacy_Version=9.1.7
ARG Octopus_Cli_Version=2.20.1
ARG Octopus_Client_Version=20.3.2503
ARG Powershell_Version=7.5.4
ARG Python_Version=3.14.2
ARG ScriptCs_Version=0.17.1
ARG Terraform_Version=1.14.3

# Install Choco
RUN $ProgressPreference = 'SilentlyContinue'; `
    Set-ExecutionPolicy Bypass -Scope Process -Force; `
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; `
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Install dotnet 8.0+
RUN Invoke-WebRequest 'https://dotnet.microsoft.com/download/dotnet/scripts/v1/dotnet-install.ps1' -outFile 'dotnet-install.ps1'; `
    [Environment]::SetEnvironmentVariable('DOTNET_CLI_TELEMETRY_OPTOUT', '1', 'Machine'); `
    .\dotnet-install.ps1 -Channel '8.0'; `
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
RUN Invoke-WebRequest "https://dl.k8s.io/release/v${Env:Kubectl_Version}/bin/windows/amd64/kubectl.exe" -OutFile .\kubectl.exe; `
    mv .\kubectl.exe C:\Windows\system32\;

# Install Kubelogin
RUN choco install azure-kubelogin --version $Env:Kubelogin_Version --no-progress -y

# Install helm 3
RUN choco install -y kubernetes-helm --version $Env:Helm_Version --no-progress

# Install Terraform
RUN choco install -y terraform --version $Env:Terraform_Version --no-progress

# Install python
RUN choco install -y python3 --version $Env:Python_Version --no-progress; `
    Import-Module $env:ChocolateyInstall\helpers\chocolateyProfile.psm1; `
    Update-SessionEnvironment

# Install 7ZIP because gcloud
RUN choco install 7zip -y --version $Env:7Zip_Version --no-progress

# Install gcloud
RUN Invoke-WebRequest "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${Env:Google_Cloud_Cli_Version}-windows-x86_64.zip" -OutFile google-cloud-sdk-$Env:Google_Cloud_Cli_Version-windows-x86_64.zip; `
    # # UNZIP AND INSTALL gcloud
    & '.\Program Files\7-Zip\7z.exe' x .\google-cloud-sdk-$Env:Google_Cloud_Cli_Version-windows-x86_64.zip; `
    .\google-cloud-sdk\install.bat --quiet; `
    rm .\google-cloud-sdk-$Env:Google_Cloud_Cli_Version-windows-x86_64.zip

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

# Install Powershell Core
RUN choco install powershell-core --yes --version $Env:Powershell_Version --no-progress

# Install Git
RUN choco install git.install --yes --version $Env:Git_Version --no-progress

# Install Argo CD
RUN choco install argocd-cli --yes --version $Env:Argo_Cli_Version --no-progress

# Update path for new tools
ADD .\scripts\update_path.cmd C:\update_path.cmd
RUN .\update_path.cmd;

# gcloud requires python on path, update_path.cmd adds python to path. Delete any backup files that exist (~1gb)
RUN gcloud components install gke-gcloud-auth-plugin --quiet; `
    if (Test-Path C:\google-cloud-sdk\.install\.backup) {Remove-Item -Path C:\google-cloud-sdk\.install\.backup -Force -Recurse}
