# Worker Tools
Officially sanctioned worker images for Octopus Deploy available on [docker hub](https://hub.docker.com/r/octopusdeploy/worker-tools)

## How to Use the Image

See the docs to get started using a worker-tools image as an [execution container for workers](https://octopus.com/docs/deployment-process/execution-containers-for-workers).

## Testing

To run these tests, you can see the instructions for [Ubuntu](#Ubuntu) and [Windows](#Windows)

N.B. all commands below should be run from the project root directory.

### Ubuntu

Our tests are implemented in `serverspec`, which relies on `ruby` and `rspec`.

#### Option 1: Build and Test scripts

```bash
./build.sh --image-directory=`ubuntu.18.04`
```

Runs a build and test of the `ubuntu.18.04` container

#### Option 2: DIY

```bash
cd ubuntu.18.04
docker build . -t worker-tools
docker build . -t worker-tools-tests -f Tests.Dockerfile --build-arg ContainerUnderTest=worker-tools
docker run -it -v `pwd`:/app worker-tools-tests
```

Then within the running docker container

```bash
cd app && bundle install && bundle exec rspec
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
docker run -it -v ${pwd}:c:\app worker-tools-tests powershell
```

Then within the running docker container

```powershell
cd c:\app
Invoke-Pester spec\windows.ltsc2019* -EnableExit
```
