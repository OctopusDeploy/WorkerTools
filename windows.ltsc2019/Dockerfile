# escape=`

FROM mcr.microsoft.com/windows/servercore:ltsc2019
SHELL ["powershell", "-Command"]

# Install Choco
RUN Set-ExecutionPolicy Bypass -Scope Process -Force
RUN [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
RUN iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Install dotnet 3+
RUN Invoke-WebRequest 'https://dot.net/v1/dotnet-install.ps1' -outFile 'dotnet-install.ps1'
RUN .\dotnet-install.ps1
RUN rm dotnet-install.ps1

# Install JDK
RUN choco install openjdk14 --allow-empty-checksums --yes --no-progress
RUN refreshenv

# Install Azure CLI
# This currently isn't working, and I'm unsure why
# https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-windows?view=azure-cli-latest
RUN Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi; Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'; rm .\AzureCLI.msi

# # Install AWS CLI
# # https://docs.aws.amazon.com/powershell/latest/userguide/pstools-getting-set-up-windows.html#ps-installing-awspowershellnetcore
RUN Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
RUN Install-Module -name AWSPowerShell.NetCore -RequiredVersion 4.0.5 -Force

# # Install NodeJS
RUN choco install nodejs-lts -y --version 12.16.2

# # Install kubectl
RUN Invoke-WebRequest "https://storage.googleapis.com/kubernetes-release/release/v1.18.0/bin/windows/amd64/kubectl.exe" -OutFile .\kubectl.exe;  mv .\kubectl.exe C:\Windows\system32\;


# # Install helm 3
RUN choco install -y kubernetes-helm --version 3.1.2


# # Install Terraform
RUN choco install -y terraform --version 0.12.24

# # Install python
RUN choco install -y python3 --version 3.8.2

# # Install 7ZIP because gcloud
RUN choco install 7zip -y --version 19.0
# # Install gcloud
RUN Invoke-WebRequest "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-289.0.0-windows-x86_64.zip" -OutFile google-cloud-sdk-289.0.0-windows-x86_64.zip;

# # UNZIP AND INSTALL gcloud
ADD .\scripts\update_path.cmd C:\update_path.cmd
RUN  & '.\Program Files\7-Zip\7z.exe' x .\google-cloud-sdk-289.0.0-windows-x86_64.zip; .\google-cloud-sdk\install.bat --quiet; rm .\google-cloud-sdk-289.0.0-windows-x86_64.zip

# # Install ScriptCS
RUN choco install scriptcs -y --version 0.17.1

# # Install octo
RUN choco install octopustools -y --version 7.3.4

# # Install Octopus Client
RUN Install-Package Octopus.Client -source https://www.nuget.org/api/v2 -SkipDependencies -Force -RequiredVersion 8.4.2
RUN $path = Join-Path (Get-Item ((Get-Package Octopus.Client).source)).Directory.FullName "lib/net452/Octopus.Client.dll"; Add-Type -Path $path; echo $path;

# # Install eksctl
RUN choco install eksctl -y --version 0.23.0

# # Update path for new tools
RUN .\update_path.cmd;
