class Release {
    [string]$ReleaseId
    [string]$ProjectId
    [DateTime]$CreatedDate
    
    Release($releaseId, $projectId) {
        $this.ReleaseId = $releaseId
        $this.ProjectId = $projectId
    }

    Release($releaseId, $projectId, $createdDate) {
        $this.ReleaseId = $releaseId
        $this.ProjectId = $projectId
        $this.CreatedDate = $createdDate
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
