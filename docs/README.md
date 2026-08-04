## Image Release Process

**Note: Unless a semantic version build tag is set on the commit being triggered, TeamCity will generate a pre-release build of the images. This should not go out to Production**

## 👷 Build
When a change is made to a file in this repository, TeamCity triggers the [full build chain](https://build.octopushq.com/buildConfiguration/OctopusDeploy_WorkerTools_ChainBuildTestAndRelease).
This results in a build of all the different distro's dockerfiles, as well as seperate architecture for non-windows os.

As part of this build process, individual images are pushed to the internal artifactory image repository.

## 🐙 Deploy
As the end of a successful build, a release is created in the [Worker Tools vNext](https://deploy.octopus.app/app#/Spaces-1163/projects/worker-tools-vnext/deployments?groupBy=Channel") Octopus Deploy Project.

This project takes the individually built images from Artifactory, and pushes them to a target repository as well as a multi-arch image to that same registry. As we create multiple architecture images for `Ubuntu 24.04` (amd64 and arm64), an additional `ubuntu.24.04` multi-arch image is created and pushed.


For the `Staging` environment the target is the same Artifactory registry where they are pushed during the build chain so then individual image push essentially becomes a no-op. The multi-arch images however will still be pushed.
For `Production` the target repository is the [public DockerHub registry](https://hub.docker.com/r/octopusdeploy/worker-tools).

## Flow Diagram

```mermaid
flowchart TD
    subgraph  repo[🧑‍💻 This Git Repository]
        direction LR
        
RepoDirs@{ shape: docs, label: "Per Platform Docker Config

* _ubuntu.22.04_
* _ubuntu.24.04_
* _windows.ltsc2022_
* _windows.ltsc2025_"}
    end

    subgraph ci[👷 Team City]
      Chain[Chain: Build Test & Release]
      ReleaseAll[Release:All]
      Builds@{ shape: docs, label: "Per Platform Build Config

* _ubuntu 22.04_
* _ubuntu 22.04 x64_
* _Windows 2022_
* _Windows 2025_"}
      Chain --> ReleaseAll
      ReleaseAll --> Builds



      click Chain "https://build.octopushq.com/project/OctopusDeploy_WorkerTools?mode=builds#all-projects" "TeamCity"
    end

    subgraph Artifactory[📦 Artifactory]
        ArtifactoryWorkerTools[docker.packages.octopushq.com/octopusdeploy/workertools]
    end

    subgraph DockerHub[📦 Docker Hub]
        DockerHubWorkerTools[docker.io/octopusdeploy/worker-tools]
        click DockerHubWorkerTools "https://hub.docker.com/r/octopusdeploy/worker-tools"
    end

    subgraph Octopus[🐙 Octopus Deploy]
      subgraph Project[Worker Tools vNext]

        Staging
        Prod
        Staging-->Prod
      end
      click Prod "https://deploy.octopus.app/app#/Spaces-1163/projects/worker-tools-vnext/deployments?groupBy=Channel"
      click Staging "https://deploy.octopus.app/app#/Spaces-1163/projects/worker-tools-vnext/deployments?groupBy=Channel"
    end

    Builds --> ArtifactoryWorkerTools

Artifactory -.-> Staging
Artifactory -.-> Prod
Staging --> |Push MultiArch Image|ArtifactoryWorkerTools
Prod --> |Push OS Images|DockerHubWorkerTools
Prod --> |Push MultiArch Image|DockerHubWorkerTools
Prod --> |Push Latest Tag|DockerHubWorkerTools
repo moving2@==> |CI trigger|ci

ReleaseAll moving1@==> |On Success|Staging

moving1@{ animate: true }
moving2@{ animate: true }

```

## Consumption in Octopus Deploy
When presented with the option to run an `Execution Container Image`, users can select this pre-built worker-tool image.

<img width="622" height="552" alt="image" src="https://github.com/user-attachments/assets/b5f7a489-bfe6-4c1e-9f28-944681afe6b3" />

The list of images presented is dynamically retrieved from DockerHub and so, once the image has been pushed to `Production`, it potentially becomes the default image that customer will use when configuring a new step. 

Unfortunately if the image is not yet cached on the Dynamic Worker VM Image, cloud customers may find that the image pull process takes an unreasonable amount of time. For this reason, it is reccomended that pushing to `Production` is only done once the new image has been sucessfully cached in the available Dynamic Worker VM.

## Dynamic Worker Images
TODO: Add To This
