ARG TARGETPLATFORM=linux/arm64

FROM --platform=$TARGETPLATFORM ubuntu:24.04

# Redeclare to make available in this build stage
ARG TARGETPLATFORM

ENV DEBIAN_FRONTEND=noninteractive

ARG Argocd_Version=2.14.21
ARG Aws_Cli_Version=2.24.10
ARG Aws_Iam_Authenticator_Version=0.7.9
ARG Aws_Powershell_Version=4.1.734
ARG Azure_Cli_Version=2.67.0-1~noble
ARG Azure_Powershell_Version=13.0.0
ARG Dotnet_Sdk_Version=8.0
ARG Ecs_Cli_Version=1.21.0
ARG Eks_Cli_Version=v0.220.0
ARG Google_Cloud_Cli_Version=550.0.0-0
ARG Google_Cloud_Gke_Cloud_Auth_Plugin_Version=550.0.0-0
ARG Helm_Version=v3.16.4
ARG Java_Jdk_Version=21
ARG Kubectl_Version=1.32
ARG Kubelogin_Version=v0.1.6
ARG NodeJs_Version=22
ARG Octopus_Cli_Version=2.20.1
ARG Octopus_Client_Version=14.3.1789
ARG Powershell_Version=7.5.4
ARG Terraform_Version=1.10.4

# Install common tools
RUN apt-get update && \
    apt-get install -y --no-install-recommends wget unzip apt-utils curl software-properties-common iputils-ping gnupg ca-certificates apt-transport-https && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install PowerShell - Architecture-specific
RUN case "$TARGETPLATFORM" in \
        "linux/amd64") PWSH_ARCH="x64" ;; \
        "linux/arm64") PWSH_ARCH="arm64" ;; \
        *) echo "Unsupported platform: $TARGETPLATFORM" && exit 1 ;; \
    esac && \
    wget -q https://github.com/PowerShell/PowerShell/releases/download/v${Powershell_Version}/powershell-${Powershell_Version}-linux-${PWSH_ARCH}.tar.gz && \
    mkdir -p /opt/microsoft/powershell/7 && \
    tar zxf powershell-${Powershell_Version}-linux-${PWSH_ARCH}.tar.gz -C /opt/microsoft/powershell/7 && \
    chmod +x /opt/microsoft/powershell/7/pwsh && \
    ln -s /opt/microsoft/powershell/7/pwsh /usr/bin/pwsh && \
    rm powershell-${Powershell_Version}-linux-${PWSH_ARCH}.tar.gz

# Install Octopus/Octo CLI
RUN apt-get update && \
    curl -fsSL https://apt.octopus.com/public.key | gpg --dearmor -o /etc/apt/keyrings/octopus.gpg && \
    ARCH=$(dpkg --print-architecture) && \
    printf "deb [arch=%s signed-by=/etc/apt/keyrings/octopus.gpg] https://apt.octopus.com/ stable main\n" "$ARCH" > /etc/apt/sources.list.d/octopus.list && \
    apt-get update && \
    apt-get install -y octopus-cli=${Octopus_Cli_Version} && \
    apt-get clean && \
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
# https://learn.microsoft.com/en-us/dotnet/core/install/linux-ubuntu-install?pivots=os-linux-ubuntu-2404&tabs=dotnet10
RUN DOTNET_CLI_TELEMETRY_OPTOUT=1 && \
    touch /etc/apt/preferences && \
    echo "Package: dotnet* aspnet* netstandard* \nPin: origin \"packages.microsoft.com\" \nPin-Priority: -10" > /etc/apt/preferences && \
    echo "export DOTNET_CLI_TELEMETRY_OPTOUT=1" > /etc/profile.d/set-dotnet-env-vars.sh && \
    apt-get update && \
    apt-get install -y dotnet-sdk-${Dotnet_Sdk_Version} && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install JDK / Tools
# https://ubuntuhandbook.org/index.php/2025/03/install-openjdk-24-ubuntu/
RUN apt-get update && \
    apt-get install -y --no-install-recommends openjdk-${Java_Jdk_Version}-jdk-headless maven gradle && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# # Install Azure CLI
# # https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt#option-2-step-by-step-installation-instructions
RUN mkdir -p /etc/apt/keyrings && \
    curl -sLS https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /etc/apt/keyrings/microsoft.gpg > /dev/null && \
    chmod go+r /etc/apt/keyrings/microsoft.gpg && \
    AZ_DIST=$(lsb_release -cs) && \
    printf "Types: deb\nURIs: https://packages.microsoft.com/repos/azure-cli/\nSuites: %s\nComponents: main\nArchitectures: %s\nSigned-by: /etc/apt/keyrings/microsoft.gpg\n" "${AZ_DIST}" "$(dpkg --print-architecture)" | tee /etc/apt/sources.list.d/azure-cli.sources && \
    apt-get update && \
    apt-get install -y azure-cli=${Azure_Cli_Version} && \
    apt-get clean && \
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
    apt-get install -y kubectl=${Kubectl_Version}.* && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Kubelogin - Architecture-specific
RUN case "$TARGETPLATFORM" in \
        "linux/amd64") KUBELOGIN_ARCH="amd64" ;; \
        "linux/arm64") KUBELOGIN_ARCH="arm64" ;; \
        *) echo "Unsupported platform: $TARGETPLATFORM" && exit 1 ;; \
    esac && \
    wget --quiet https://github.com/Azure/kubelogin/releases/download/${Kubelogin_Version}/kubelogin-linux-${KUBELOGIN_ARCH}.zip && \
    unzip kubelogin-linux-${KUBELOGIN_ARCH}.zip -d kubelogin-linux-${KUBELOGIN_ARCH} && \
    mv kubelogin-linux-${KUBELOGIN_ARCH}/bin/linux_${KUBELOGIN_ARCH}/kubelogin /usr/local/bin && \
    rm -rf kubelogin-linux-${KUBELOGIN_ARCH} && \
    rm kubelogin-linux-${KUBELOGIN_ARCH}.zip

# Install Terraform - Architecture-specific
# https://computingforgeeks.com/how-to-install-terraform-on-ubuntu-centos-7/
RUN case "$TARGETPLATFORM" in \
        "linux/amd64") TERRAFORM_ARCH="amd64" ;; \
        "linux/arm64") TERRAFORM_ARCH="arm64" ;; \
        *) echo "Unsupported platform: $TARGETPLATFORM" && exit 1 ;; \
    esac && \
    wget --quiet https://releases.hashicorp.com/terraform/${Terraform_Version}/terraform_${Terraform_Version}_linux_${TERRAFORM_ARCH}.zip && \
    unzip terraform_${Terraform_Version}_linux_${TERRAFORM_ARCH}.zip && \
    mv terraform /usr/local/bin && \
    rm terraform_${Terraform_Version}_linux_${TERRAFORM_ARCH}.zip

# Install Google Cloud CLI - Architecture-specific recommended install method
# https://docs.cloud.google.com/sdk/docs/install-sdk
RUN case "$TARGETPLATFORM" in \
        "linux/amd64") GCLOUD_ARCH="x86_64" ;; \
        "linux/arm64") GCLOUD_ARCH="arm" ;; \
        *) echo "Unsupported platform: $TARGETPLATFORM" && exit 1 ;; \
    esac && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \


    curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-${GCLOUD_ARCH}.tar.gz && \
    tar -xf google-cloud-cli-linux-${GCLOUD_ARCH}.tar.gz && \
    ./google-cloud-sdk/install.sh --quiet --usage-reporting false --path-update true && \
    ln -s /google-cloud-sdk/bin/gcloud /usr/local/bin/gcloud && \
    ln -s /google-cloud-sdk/bin/gsutil /usr/local/bin/gsutil && \
    rm google-cloud-cli-linux-${GCLOUD_ARCH}.tar.gz

# Install pip & groff
# Ubuntu 24.04 requires --break-system-packages due to PEP 668
# https://peps.python.org/pep-0668/
RUN apt-get update && \
    apt-get install -y python3-pip groff && \
    python3 -m pip install pycryptodome --user --break-system-packages && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


# # Install AWS CLI
# # https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
RUN case "$TARGETPLATFORM" in \
        "linux/amd64") AWS_CLI_ARCH="x86_64" ;; \
        "linux/arm64") AWS_CLI_ARCH="aarch64" ;; \
        *) echo "Unsupported platform: $TARGETPLATFORM" && exit 1 ;; \
    esac && \
    curl -L "https://awscli.amazonaws.com/awscli-exe-linux-${AWS_CLI_ARCH}-${Aws_Cli_Version}.zip" -o "awscliv2.zip" && \
    unzip -q awscliv2.zip && \
    ./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli && \
    rm -f awscliv2.zip && \
    rm -rf ./aws

# Install EKS CLI
# https://github.com/weaveworks/eksctl
RUN case "$TARGETPLATFORM" in \
        "linux/amd64") EKS_CLI_ARCH="amd64" ;; \
        "linux/arm64") EKS_CLI_ARCH="arm64" ;; \
        *) echo "Unsupported platform: $TARGETPLATFORM" && exit 1 ;; \
    esac && \
    curl --silent --location "https://github.com/eksctl-io/eksctl/releases/download/v0.220.0/eksctl_Linux_${EKS_CLI_ARCH}.tar.gz" | tar xz -C /tmp && \
    mv /tmp/eksctl /usr/local/bin

# Install ECS CLI
## https://github.com/aws/amazon-ecs-cli
RUN case "$TARGETPLATFORM" in \
        "linux/amd64") ECS_CLI_ARCH="amd64" ;; \
        "linux/arm64") ECS_CLI_ARCH="arm64" ;; \
        *) echo "Unsupported platform: $TARGETPLATFORM" && exit 1 ;; \
    esac && \
    curl --silent --location "https://amazon-ecs-cli.s3.amazonaws.com/ecs-cli-linux-${ECS_CLI_ARCH}-v${Ecs_Cli_Version}" -o /usr/local/bin/ecs-cli && \
    chmod +x /usr/local/bin/ecs-cli

# Install AWS IAM Authenticator
# https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html
RUN case "$TARGETPLATFORM" in \
        "linux/amd64") AWS_IAM_ARCH="amd64" ;; \
        "linux/arm64") AWS_IAM_ARCH="arm64" ;; \
        *) echo "Unsupported platform: $TARGETPLATFORM" && exit 1 ;; \
    esac && \ 
    curl --silent --location https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v${Aws_Iam_Authenticator_Version}/aws-iam-authenticator_${Aws_Iam_Authenticator_Version}_linux_${AWS_IAM_ARCH} -o /usr/local/bin/aws-iam-authenticator && \
    chmod +x /usr/local/bin/aws-iam-authenticator

## Install Istio CLI
## https://istio.io/docs/ops/diagnostic-tools/istioctl/
RUN curl -sL https://istio.io/downloadIstioctl | sh - && \
    mv /root/.istioctl/bin/istioctl /usr/local/bin/istioctl && \
    rm -rf /root/.istioctl

# Install Linkerd CLI
# https://linkerd.io/2-edge/getting-started/
RUN curl --proto '=https' --tlsv1.2 -sSfL https://run.linkerd.io/install-edge | sh && \
    export PATH=$HOME/.linkerd2/bin:$PATH


# Install Argo CD
RUN case "$TARGETPLATFORM" in \
        "linux/amd64") ARGO_ARCH="amd64" ;; \
        "linux/arm64") AROG_ARCH="arm64" ;; \
        *) echo "Unsupported platform: $TARGETPLATFORM" && exit 1 ;; \
    esac && \ 
curl -sSL -o argocd-linux-${ARGO_ARCH} https://github.com/argoproj/argo-cd/releases/download/v${Argocd_Version}/argocd-linux-${ARGO_ARCH} && \
install -m 555 argocd-linux-${ARGO_ARCH} /usr/local/bin/argocd && \
rm argocd-linux-${ARGO_ARCH}

# Get common utilities for scripting
# https://mikefarah.gitbook.io/yq/
# https://augeas.net/
# Install yq from GitHub releases (PPA doesn't support Ubuntu 24.04)
RUN apt-get update && apt-get install -y jq openssh-client rsync git augeas-tools xxd && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    case "$TARGETPLATFORM" in \
        "linux/amd64") YQ_ARCH="amd64" ;; \
        "linux/arm64") YQ_ARCH="arm64" ;; \
        *) echo "Unsupported platform: $TARGETPLATFORM" && exit 1 ;; \
    esac && \
    wget --quiet https://github.com/mikefarah/yq/releases/latest/download/yq_linux_${YQ_ARCH} -O /usr/bin/yq && \
    chmod +x /usr/bin/yq

RUN rm -rf /usr/share/doc /usr/share/man /usr/share/info /var/cache/*
