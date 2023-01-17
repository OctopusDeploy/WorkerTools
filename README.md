# Worker Tools

Officially sanctioned worker images for Octopus Deploy available on [docker hub](https://hub.docker.com/r/octopusdeploy/worker-tools)

| Operating System         | Installed Tools and Versions                                                                                                                         |
|--------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------|
| Ubuntu 22.04              | [Installed tools](./ubuntu.22.04/README.md) ([Dockerfile](https://github.com/OctopusDeploy/WorkerTools/blob/master/ubuntu.22.04/Dockerfile))         |
| Windows Server Core 2019 | [Installed tools](./windows.ltsc2019/README.md) ([Dockerfile](https://github.com/OctopusDeploy/WorkerTools/blob/master/windows.ltsc2019/Dockerfile)) |

## Management

The Worker Tools images provided by this repository are currently updated on a best-effort basis. This repository should contain the latest stable versions of all of the tools.

If you want a tool version that is not yet available, PRs are welcome. 

If the tools or the way they are managed don't fit your particular use case, it is easy to [create your own images](https://octopus.com/docs/projects/steps/execution-containers-for-workers#which-image) to use as execution containers.

## Getting Started

See the docs to get started using the `octopusdeploy/worker-tools` image as an [execution container for workers](https://octopus.com/docs/deployment-process/execution-containers-for-workers).

The images we publish are [semantically versioned](https://semver.org/). To ensure stability within your deployment processes, we recommend using the full `major.minor.patch` tag when using the `octopusdeploy/worker-tools` image - for example, use `2.0.2-ubuntu.22.04`, not `ubuntu.22.04`.

## Contributing

### Testing

To run these tests, you can see the instructions for [Ubuntu](#Ubuntu) and [Windows](#Windows)

N.B. all commands below should be run from the project root directory.

### Ubuntu

Our tests are implemented in `Pester`, which relies on `PowerShell`.

#### Option 1: Build and Test scripts

```bash
./build.sh --image-directory='ubuntu.22.04'
```

Runs a build and test of the `ubuntu.22.04` container

#### Option 2: DIY

```bash
cd ubuntu.22.04
docker build . -t worker-tools
docker build . -t worker-tools-tests -f Tests.Dockerfile --build-arg ContainerUnderTest=worker-tools
docker run -it -v `pwd`:/app worker-tools-tests pwsh
```

Then within the running docker container

```powershell
/app/scripts/run-tests.ps1
```

### Windows

#### Option 1: Build and Test scripts

```powershell
build.ps1 -image-directory 'windows.ltsc2019'
```

Runs a build and test of the `windows.ltsc2019` container

#### Option 2: DIY

```powershell
cd windows.ltsc2019
docker build . -t worker-tools
docker build . -t worker-tools-tests -f Tests.Dockerfile --build-arg ContainerUnderTest=worker-tools
docker run -it -v ${pwd}:c:\app worker-tools-tests pwsh
```

Then within the running docker container

```powershell
/app/scripts/run-tests.ps1
```
