//////////////////////////////////////////////////////////////////////
// TOOLS
//////////////////////////////////////////////////////////////////////
#tool "nuget:?package=GitVersion.CommandLine&version=4.0.0"
#addin "nuget:?package=Cake.Docker&version=0.10.0"
#addin "nuget:?package=Cake.Incubator&version=5.1.0"

using Cake.Incubator.LoggingExtensions;

//////////////////////////////////////////////////////////////////////
// ARGUMENTS
//////////////////////////////////////////////////////////////////////
var target = Argument("target", "Default");

///////////////////////////////////////////////////////////////////////////////
// GLOBAL VARIABLES
///////////////////////////////////////////////////////////////////////////////
var artifactsDir = "./artifacts";

string nugetVersion;

///////////////////////////////////////////////////////////////////////////////
// SETUP / TEARDOWN
///////////////////////////////////////////////////////////////////////////////
Setup(context =>
{
    var fromEnv = context.EnvironmentVariable("GitVersion.NuGetVersion");
    
    if (string.IsNullOrEmpty(fromEnv))
    { 
        var gitVersionInfo = GitVersion(new GitVersionSettings {
            OutputType = GitVersionOutput.Json
        });
        nugetVersion = gitVersionInfo.NuGetVersion;
        Information("Building worker images v{0}", nugetVersion);
        Information("Informational Version {0}", gitVersionInfo.InformationalVersion);
        Verbose("GitVersion:\n{0}", gitVersionInfo.Dump());
    }
    else
    {
        nugetVersion = fromEnv;
        Information("Building woeker images v{0}", nugetVersion);
    }

    if (BuildSystem.IsRunningOnTeamCity)
        BuildSystem.TeamCity.SetBuildNumber(nugetVersion);
});

Teardown(context =>
{
    Information("Finished running tasks for build v{0}", nugetVersion);
});

//////////////////////////////////////////////////////////////////////
//  PRIVATE TASKS
//////////////////////////////////////////////////////////////////////

Task("Build")
    .Does(() =>
{
    var tag = $"octopusdeploy/worker-prerelease:{nugetVersion}-ubuntu1804";
    DockerBuild(new DockerImageBuildSettings { Tag = new [] { tag } }, "ubuntu.18.04");
});

//////////////////////////////////////////////////////////////////////
// TASKS
//////////////////////////////////////////////////////////////////////
Task("Default")
    .IsDependentOn("Build");

//////////////////////////////////////////////////////////////////////
// EXECUTION
//////////////////////////////////////////////////////////////////////
RunTarget(target);
