class Release {
    [string]$ReleaseId
    [string]$ProjectId
    
    Release($releaseId, $projectId) {
        $this.ReleaseId = $releaseId
        $this.ProjectId = $projectId
    }
}

class Deployment {
    [string]$DeploymentId
    [string]$ReleaseId
    [string]$EnvironmentId

    Deployment($deploymentId, $releaseId, $environmentId) {
        $this.DeploymentId = $deploymentId
        $this.ReleaseId = $releaseId
        $this.EnvironmentId = $environmentId
    }
}
