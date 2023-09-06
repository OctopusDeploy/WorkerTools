ARG ContainerUnderTest=octopusdeploy/worker-tools

FROM ${ContainerUnderTest}
SHELL ["powershell", "-Command"]