# About This Image

These images include common tools used for Octopus steps and are the recommended images to use when setting up [execution containers for workers](https://octopus.com/docs/deployment-process/execution-containers-for-workers).

For an Octopus deployment [step](https://octopus.com/docs/deployment-process/steps) running on a [worker](https://octopus.com/docs/infrastructure/workers) or the [Octopus Server](https://octopus.com/docs/infrastructure/workers/built-in-worker), you can select a container for the step's execution.

# How to Use the Image

Pick an image that is suitable for your needs based on OS + distribution.

| Operating System         | Installed Tools and Versions                                                                                                                         |
|--------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------|
| Ubuntu 22.04             | [Installed tools](./ubuntu.22.04/README.md) ([Dockerfile](https://github.com/OctopusDeploy/WorkerTools/blob/master/ubuntu.22.04/Dockerfile))         |
| Windows Server Core 2019 | [Installed tools](./windows.ltsc2019/README.md) ([Dockerfile](https://github.com/OctopusDeploy/WorkerTools/blob/master/windows.ltsc2019/Dockerfile)) |

The images we publish have multiple release tracks, and are [semantically versioned](https://semver.org/). To ensure stability within your deployment processes, we recommend using the full `major.minor.patch` tag when using the `octopusdeploy/worker-tools` image - for example, use `2.0.2-ubuntu.22.04`, not `ubuntu.22.04`, unless you have a particular use-case that is more tolerant of changes.

Release Track  | Ubuntu             | Windows 
---------|--------------------| ---
latest | ubuntu.22.04       | windows.ltsc2019
Major | 1-ubuntu.22.04     | 1-windows.ltsc2019
Major.Minor | 1.0-ubuntu.22.04   | 1.0-windows.ltsc2019
Major.Minor.Patch | 1.0.1-ubuntu.22.04 | 1.0.2-windows.ltsc2019

# Full Tag Listing

## Windows Server 2019 amd64 Tags
Tag | Dockerfile
---------| ---------------
windows.ltsc2019 | [Dockerfile](https://github.com/OctopusDeploy/WorkerTools/blob/master/windows.ltsc2019/Dockerfile)

## Ubuntu Tags
Tag | Dockerfile
---------| ---------------
ubuntu.22.04 | [Dockerfile](https://github.com/OctopusDeploy/WorkerTools/blob/master/ubuntu.22.04/Dockerfile)

You can retrieve a list of all available tags for octopusdeploy/worker-tools at https://hub.docker.com/v2/repositories/octopusdeploy/worker-tools/tags.
