using System;
using System.IO;
using System.Linq;
using JetBrains.Annotations;
using Nuke.Common;
using Nuke.Common.CI;
using Nuke.Common.Tools.Docker;
using Nuke.Common.Execution;
using Nuke.Common.IO;
using Nuke.Common.ProjectModel;
using Nuke.Common.Tooling;
using Nuke.Common.Tools.OctoVersion;
using Nuke.Common.Utilities.Collections;
using Serilog;
using static Nuke.Common.EnvironmentInfo;
using static Nuke.Common.IO.FileSystemTasks;
using static Nuke.Common.IO.PathConstruction;

class Build : NukeBuild
{
    /// Support plugins are available for:
    ///   - JetBrains ReSharper        https://nuke.build/resharper
    ///   - JetBrains Rider            https://nuke.build/rider
    ///   - Microsoft VisualStudio     https://nuke.build/visualstudio
    ///   - Microsoft VSCode           https://nuke.build/vscode
    [Parameter("Configuration to build - Default is 'Debug' (local) or 'Release' (server)")]
    readonly Configuration Configuration = IsLocalBuild ? Configuration.Debug : Configuration.Release;

    [Parameter(
        "Whether to auto-detect the branch name - this is okay for a local build, but should not be used under CI.")]
    readonly bool AutoDetectBranch = IsLocalBuild;

    [Parameter(
        "Branch name for OctoVersion to use to calculate the version number. Can be set via the environment variable OCTOVERSION_CurrentBranch.",
        Name = "OCTOVERSION_CurrentBranch")]
    readonly string BranchName;

    [OctoVersion(UpdateBuildNumber = true, BranchMember = nameof(BranchName),
        AutoDetectBranchMember = nameof(AutoDetectBranch), Framework = "net6.0")]
    readonly OctoVersionInfo OctoVersionInfo;

    [Parameter("Whether to force use the Linux build")] readonly bool? UseLinux;

    string OsName
    {
        get
        {
            if (UseLinux.HasValue)
            {
                return UseLinux.Value ? LinuxVersion : WindowsVersion;
            }
            
            return OperatingSystem.IsWindows() ? WindowsVersion : LinuxVersion;
        }
    }
    
    AbsolutePath ImageDirectory => RootDirectory / OsName;

    string ImageName
    {
        get
        {
            var name = OperatingSystem.IsWindows() ? WindowsVersion : LinuxVersion;

            return string.IsNullOrEmpty(OctoVersionInfo?.FullSemVer)
                ? $"{ImageBaseName}:{name}"
                : $"{ImageBaseName}:{name}-{OctoVersionInfo.FullSemVer}";
        }
    }

    const string ImageBaseName = "docker.packages.octopushq.com/octopusdeploy/worker-tools";

    const string LinuxVersion = "ubuntu.22.04";
    const string WindowsVersion = "windows.ltsc2019";
    
    Target BuildImage => _ => _
        .Executes(() =>
        {
            DockerTasks.DockerBuild(x => x
                .SetPath(OsName)
                .SetTag(ImageName)
                .EnableQuiet());
        });
    
    Target TestImage => _ => _
        .DependsOn(BuildImage)
        .Executes(() =>
        {
            DockerTasks.DockerRun(x => x
                .AddVolume($"{ImageDirectory}:/app")
                .SetWorkdir("/app")
                .SetEntrypoint("pwsh")
                .SetCommand("scripts/run-tests.ps1")
                .SetImage(ImageName));
        });

    Target PushImage => _ => _
        .DependsOn(TestImage)
        .Executes(() =>
        {
            DockerTasks.DockerPush(x => x.SetName(ImageName));
        });

    // Target BuildManifest => _ => _
    //     .Executes(() =>
    //     {
    //         DockerTasks.DockerManifestCreate(s => s.AddManifests());
    //         
    //     });

    // Target Default => _ => _
    //     .DependsOn(Pack)
    //     .DependsOn(CopyToLocalPackages);

    public static int Main() => Execute<Build>(x => x.BuildImage);
}