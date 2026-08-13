## Image Release Process

**⚠️ Note: Unless a semantic version build tag is set on the commit being triggered, TeamCity will generate a pre-release build of the images. This should not go out to Production**

1. `GitHub` Dockerfile Per Platform
2. `TeamCity` [Chain:ReleaseAll](https://build.octopushq.com/project/OctopusDeploy_WorkerTools?mode=builds#all-projects)
3. `Octopus (Dev)` Push to Artifactory
4. Wait For Worker Tools VM to push to Production Tenants (see below)
5. `Octopus (Prod)` Push to DockerHub

## 👷 Build
When a change is made to a file in this repository, TeamCity triggers the [full build chain](https://build.octopushq.com/buildConfiguration/OctopusDeploy_WorkerTools_ChainBuildTestAndRelease).
This results in a build of all the different distro's dockerfiles, as well as seperate architecture for non-windows os.

As part of this build process, individual images are pushed to the internal artifactory image repository.

## 📦 Artifact Storage
* **Artifactory**: (pre-prod) _docker.packages.octopushq.com/octopusdeploy/workertools_
* **DockerHub** (prod) [docker.io/octopusdeploy/worker-tools](https://hub.docker.com/r/octopusdeploy/worker-tools)

## 🐙 Deploy
The deployment process in [Worker Tools vNext](https://deploy.octopus.app/app#/Spaces-1163/projects/worker-tools-vnext/deployments?groupBy=Channel) performs some Image manipulation/pushing.
1. Pull each Image from Artifactory (where TC Build Pushes each)
2. Push each Image to target registry (results in a no-op for pre-prod which uses the same Artifactory registry it just pushed from
3. Create multi-arch `:<version>` taged image across all distros and push to target registry
4. Create multi-arch `:ubuntu-<version>` image and push to target registry (Windows does not support ARM so no need)
5. 
**⚠️ Note: Until the Cloud infrastructure has been updated to use a Dynamic Worker VM that contains a cached version of the newly created image then it should not be pushed to production. See Below for more details.**

## Consumption in Octopus Deploy
When presented with the option to run an `Execution Container Image`, users can select this pre-built worker-tool image.

<img width="622" height="552" alt="image" src="https://github.com/user-attachments/assets/b5f7a489-bfe6-4c1e-9f28-944681afe6b3" />

The list of images presented is dynamically retrieved from DockerHub and so, once the image has been pushed to `Production`, it potentially becomes the default image that customer will use when configuring a new step. 

Unfortunately if the image is not yet cached on the Dynamic Worker VM Image, cloud customers may find that the image pull process takes an unreasonable amount of time. For this reason, it is reccomended that pushing to `Production` is only done once the new image has been sucessfully cached in the available Dynamic Worker VM.

## ☁️ Octopus Cloud Dynamic Worker Images
Not until the 
[Cloud Platform deploy space](https://deploy.octopus.app/app#/Spaces-142/projects?searchValue=Dynamic+Worker+Images&page=1&pageSize=50&hideInactiveProjects=false) contains a project per VM.

Go to the Image deployment (e.g [x](https://build.octopushq.com/buildConfiguration/CloudPlatform_DynamicWorkers_DynamicWorkerVmImages_Ubuntu2204/23691299?showLog=23691299_2731_39.67.645.2501.2731&logView=flowAware)), find the latest build and look for the line entry describing the cached versions, looking for the header `Cache Docker Images`. At the bottom of this you will see log entry
```
azure-arm.ubuntu: Selecting the following images due to maximum image count of 3 :
azure-arm.ubuntu: - "6.6.5-ubuntu.22.04"
azure-arm.ubuntu: - "6.6.4-ubuntu.22.04"
azure-arm.ubuntu: - "6.6.3-ubuntu.22.04"
```

For each of the relevant distros, check the earliest build that had the new docker image cached. 

Each Octopus Project has a `Cautious Promoter` step which runs the [Cautious Promoter](https://github.com/OctopusDeploy/CautiousPromoter) tool to determin when to push to each Production Tenant.

Once _all_ of these builds have been deployed to Production from the [Dynamic Worker Images Project](https://deploy.octopus.app/app#/Spaces-142/projects?includeProjectGroupId=ProjectGroups-1841&searchValue=Dynamic+Worker+Images&page=1&pageSize=50&hideInactiveProjects=false) Group, then the docker images can be released to production.

