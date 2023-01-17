ARG ContainerUnderTest=octopusdeploy/worker-tools

FROM ${ContainerUnderTest}
SHELL ["pwsh", "-Command"]
