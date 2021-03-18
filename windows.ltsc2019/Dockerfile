# escape=`

FROM mcr.microsoft.com/windows/servercore:ltsc2019
SHELL ["powershell", "-Command"]

# Install Choco
RUN $ProgressPreference = 'SilentlyContinue'; `
    Set-ExecutionPolicy Bypass -Scope Process -Force; `
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; `
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Install dotnet 3+
RUN Invoke-WebRequest 'https://dot.net/v1/dotnet-install.ps1' -outFile 'dotnet-install.ps1'; `
    [Environment]::SetEnvironmentVariable('DOTNET_CLI_TELEMETRY_OPTOUT', '1', 'Machine'); `
    .\dotnet-install.ps1 -Channel '3.1'; `
    rm dotnet-install.ps1

# Install JDK
RUN choco install openjdk14 --allow-empty-checksums --yes --no-progress --version 14.0.2; refreshenv

# Install Azure CLI
RUN choco install azure-cli -y --version 2.14.0 --no-progress

# Install the AWS CLI
RUN choco install awscli -y --version 2.0.60 --no-progress

# # Install AWS PowerShell module
# # https://docs.aws.amazon.com/powershell/latest/userguide/pstools-getting-set-up-windows.html#ps-installing-awspowershellnetcore
RUN Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force; `
    Install-Module -name AWSPowerShell.NetCore -RequiredVersion 4.1.2 -Force

# # Install NodeJS
RUN choco install nodejs-lts -y --version 14.15.0 --no-progress

# # Install kubectl
RUN Invoke-WebRequest "https://storage.googleapis.com/kubernetes-release/release/v1.18.8/bin/windows/amd64/kubectl.exe" -OutFile .\kubectl.exe; `
    mv .\kubectl.exe C:\Windows\system32\;

# # Install helm 3
RUN choco install -y kubernetes-helm --version 3.3.0 --no-progress

# # Install Terraform
RUN choco install -y terraform --version 0.13.4 --no-progress

# # Install python
RUN choco install -y python3 --version 3.8.5 --no-progress; `
    refreshenv

# # Install 7ZIP because gcloud
RUN choco install 7zip -y --version 19.0 --no-progress

# # Install gcloud
RUN Invoke-WebRequest "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-305.0.0-windows-x86_64.zip" -OutFile google-cloud-sdk-305.0.0-windows-x86_64.zip; `
    # # UNZIP AND INSTALL gcloud
    & '.\Program Files\7-Zip\7z.exe' x .\google-cloud-sdk-305.0.0-windows-x86_64.zip; `
    .\google-cloud-sdk\install.bat --quiet; `
    rm .\google-cloud-sdk-305.0.0-windows-x86_64.zip

# # Install ScriptCS
RUN choco install scriptcs -y --version 0.17.1 --no-progress

# # Install octo
RUN choco install octopustools -y --version 7.4.1 --no-progress

# # Install Octopus Client
RUN Install-Package Octopus.Client -source https://www.nuget.org/api/v2 -SkipDependencies -Force -RequiredVersion 8.8.3

# # Install eksctl
RUN choco install eksctl -y --version 0.25.0 --no-progress

# # Install Powershell Core
RUN choco install powershell-core --yes --version 7.0.3 --no-progress

# # Update path for new tools
ADD .\scripts\update_path.cmd C:\update_path.cmd
RUN .\update_path.cmd;
