using JetBrains.Annotations;
using Nuke.Common;
using Nuke.Common.Tools.OctoVersion;

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

    [PublicAPI]
    Target CalculateVersion => _ => _
        .Executes(() =>
        {
            // This is here just so that TeamCity has a target to call. The OctoVersion attribute generates the version for us
        });

    public static int Main() => Execute<Build>(x => x.CalculateVersion);
}