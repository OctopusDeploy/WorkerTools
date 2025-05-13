FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

ARG Argocd_Version=2.13.3
ARG Aws_Cli_Version=2.24.10
ARG Aws_Iam_Authenticator_Version=0.6.29
ARG Aws_Powershell_Version=4.1.734
ARG Azure_Cli_Version=2.67.0-1~jammy
ARG Azure_Powershell_Version=13.0.0
ARG Dotnet_Sdk_Version=8.0
ARG Ecs_Cli_Version=1.21.0
ARG Eks_Cli_Version=v0.200.0
ARG Google_Cloud_Cli_Version=505.0.0-0
ARG Google_Cloud_Gke_Cloud_Auth_Plugin_Version=505.0.0-0
ARG Helm_Version=v3.16.4
ARG Java_Jdk_Version=21
ARG Kubectl_Version=1.32
ARG Kubelogin_Version=v0.1.6
ARG NodeJs_Version=22
ARG Octopus_Cli_Legacy_Version=9.1.7
ARG Octopus_Cli_Version=2.14.0
ARG Octopus_Client_Version=14.3.1789
ARG Powershell_Version=7.4.6-1.deb
ARG Python2_Version=2.7.18-3
ARG Terraform_Version=1.10.4



# Install common tools
RUN apt-get update && \
    apt-get install -y --no-install-recommends wget unzip apt-utils curl software-properties-common iputils-ping gnupg ca-certificates apt-transport-https && \
    rm -rf /var/lib/apt/lists/*

# Install PowerShell
RUN wget -q https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    apt-get update && \
    add-apt-repository universe && \
    apt-get install -y powershell=${Powershell_Version} &&\
    rm -rf /var/lib/apt/lists/*

# Install Octopus/Octo CLI
RUN apt-get update && \
    curl -fsSL https://apt.octopus.com/public.key | gpg --dearmor -o /etc/apt/keyrings/octopus.gpg && \
    echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/octopus.gpg] https://apt.octopus.com/ stable main" | tee /etc/apt/sources.list.d/octopus.list > /dev/null && \
    apt-get update && \
    apt-get install -y octopus-cli=${Octopus_Cli_Version} octopuscli=${Octopus_Cli_Legacy_Version} && \
    rm -rf /var/lib/apt/lists/*

# Install Octopus Client
# https://octopus.com/docs/octopus-rest-api/octopus.client
RUN pwsh -c 'Install-Package -Force Octopus.Client -MaximumVersion "'${Octopus_Client_Version}'" -source https://www.nuget.org/api/v2 -SkipDependencies' && \
    octopusClientPackagePath=$(pwsh -c '(Get-Item ((Get-Package Octopus.Client).source)).Directory.FullName') && \
    cp -r $octopusClientPackagePath/lib/netstandard2.0/* . 

# Install AWS Powershell core modules
# https://docs.aws.amazon.com/powershell/latest/userguide/pstools-getting-set-up-linux-mac.html
RUN pwsh -c 'Install-Module -Force -Name AWSPowerShell.NetCore -AllowClobber -Scope AllUsers -MaximumVersion "'${Aws_Powershell_Version}'"'

# Install AZ Powershell core modules
# https://docs.microsoft.com/en-us/powershell/azure/install-az-ps?view=azps-3.6.1
RUN pwsh -c 'Install-Module -Force -Name Az -AllowClobber -Scope AllUsers -MaximumVersion "'${Azure_Powershell_Version}'"'

# Install Helm3
RUN wget --quiet -O - https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | bash -s -- -v ${Helm_Version}

# Install .NET SDK
# https://docs.microsoft.com/en-us/dotnet/core/install/linux-package-manager-ubuntu-1804
# https://learn.microsoft.com/en-us/dotnet/core/install/linux-package-mixup
RUN DOTNET_CLI_TELEMETRY_OPTOUT=1 && \
    touch /etc/apt/preferences && \
    echo "Package: dotnet* aspnet* netstandard* \nPin: origin \"packages.microsoft.com\" \nPin-Priority: -10" > /etc/apt/preferences && \
    echo "export DOTNET_CLI_TELEMETRY_OPTOUT=1" > /etc/profile.d/set-dotnet-env-vars.sh && \
    apt-get update && \
    apt-get install -y dotnet-sdk-${Dotnet_Sdk_Version} && \
    rm -rf /var/lib/apt/lists/*

# Install JDK / Tools
# https://www.digitalocean.com/community/tutorials/how-to-install-java-with-apt-on-ubuntu-18-04
# https://packages.ubuntu.com/bionic/openjdk-11-dbg
RUN apt-get update && \
    apt-get install -y --no-install-recommends openjdk-${Java_Jdk_Version}-jdk-headless maven gradle && \
    rm -rf /var/lib/apt/lists/*

# Install Azure CLI
# https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt#option-2-step-by-step-installation-instructions
RUN curl -sLS https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /etc/apt/keyrings/microsoft.gpg > /dev/null && \
    echo "deb [arch=`dpkg --print-architecture` signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/azure-cli/ jammy main" | tee /etc/apt/sources.list.d/azure-cli.list && \
    apt-get update && \
    apt-get install -y azure-cli=${Azure_Cli_Version} && \
    rm -rf /var/lib/apt/lists/* && \
    # remove az cli warning - https://github.com/Azure/arm-deploy/issues/173
    az config set bicep.use_binary_from_path=false

# Install NodeJS
RUN wget --quiet -O - https://deb.nodesource.com/setup_${NodeJs_Version}.x | bash && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install kubectl
# https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/#install-using-native-package-management
RUN curl -fsSL "https://pkgs.k8s.io/core:/stable:/v${Kubectl_Version}/deb/Release.key" | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v${Kubectl_Version}/deb/ /" | tee /etc/apt/sources.list.d/kubernetes.list && \
    apt-get update && \ 
    apt-get install -y kubectl && \
    rm -rf /var/lib/apt/lists/*

# Install Kubelogin
RUN wget --quiet https://github.com/Azure/kubelogin/releases/download/${Kubelogin_Version}/kubelogin-linux-amd64.zip && \
    unzip kubelogin-linux-amd64.zip -d kubelogin-linux-amd64 && \
    mv kubelogin-linux-amd64/bin/linux_amd64/kubelogin /usr/local/bin && \
    rm -rf kubelogin-linux-amd64 && \
    rm kubelogin-linux-amd64.zip

# Install Terraform
# https://computingforgeeks.com/how-to-install-terraform-on-ubuntu-centos-7/
RUN wget --quiet https://releases.hashicorp.com/terraform/${Terraform_Version}/terraform_${Terraform_Version}_linux_amd64.zip && \
    unzip terraform_${Terraform_Version}_linux_amd64.zip && \
    mv terraform /usr/local/bin && \
    rm terraform_${Terraform_Version}_linux_amd64.zip

# Install Google Cloud CLI
# https://cloud.google.com/sdk/docs/downloads-apt-get
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    apt-get update && apt-get install -y google-cloud-cli=${Google_Cloud_Cli_Version} google-cloud-cli-gke-gcloud-auth-plugin=${Google_Cloud_Gke_Cloud_Auth_Plugin_Version} && \
    rm -rf /var/lib/apt/lists/*

# Install pip & groff
RUN apt-get update && \
    apt-get install -y python3-pip groff && \
    python3 -m pip install pycryptodome --user && \
    rm -rf /var/lib/apt/lists/*

# Install python2
RUN apt-get update && \
    apt-get install -y python2-minimal=${Python2_Version} && \
    ln -s /usr/bin/python2 /usr/bin/python

# Install AWS CLI
# https://docs.aws.amazon.com/cli/latest/userguide/install-linux.html#install-linux-awscli
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${Aws_Cli_Version}.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm awscliv2.zip && \
    rm -rf ./aws

# Install EKS CLI
# https://github.com/weaveworks/eksctl
RUN curl --silent --location "https://github.com/weaveworks/eksctl/releases/download/${Eks_Cli_Version}/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp && \
    mv /tmp/eksctl /usr/local/bin

# Install ECS CLI
## https://github.com/aws/amazon-ecs-cli
RUN curl --silent --location "https://amazon-ecs-cli.s3.amazonaws.com/ecs-cli-linux-amd64-v${Ecs_Cli_Version}" -o /usr/local/bin/ecs-cli && \
    chmod +x /usr/local/bin/ecs-cli

# Install AWS IAM Authenticator
# https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html
RUN curl --silent --location https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v${Aws_Iam_Authenticator_Version}/aws-iam-authenticator_${Aws_Iam_Authenticator_Version}_linux_amd64 -o /usr/local/bin/aws-iam-authenticator && \
    chmod +x /usr/local/bin/aws-iam-authenticator

## Install Istio CLI
## https://istio.io/docs/ops/diagnostic-tools/istioctl/
RUN curl -sL https://istio.io/downloadIstioctl | sh - && \
    mv /root/.istioctl/bin/istioctl /usr/local/bin/istioctl && \
    rm -rf /root/.istioctl

# Install Linkerd CLI
# https://linkerd.io/2/getting-started/
RUN curl -sL https://run.linkerd.io/install | sh && \
    cp /root/.linkerd2/bin/linkerd /usr/local/bin && \
    rm -rf /root/.linkerd2

# Install Argo CD
RUN curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/download/v${Argocd_Version}/argocd-linux-amd64 && \
  install -m 555 argocd-linux-amd64 /usr/local/bin/argocd && \
  rm argocd-linux-amd64

# Get common utilities for scripting
# https://mikefarah.gitbook.io/yq/
# https://augeas.net/
RUN add-apt-repository -y ppa:rmescandon/yq && \
    apt-get update && apt-get install -y jq yq openssh-client rsync git augeas-tools xxd && \
    rm -rf /var/lib/apt/lists/*
