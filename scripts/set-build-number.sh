#!/usr/bin/env bash
set -euo pipefail

# Calculates the build number from GitVersion and emits a TeamCity service message
# to override the default build number.
#
# Notes on the GitVersion 5 -> 6 migration:
#   - GitVersion 6 dropped the `NuGetVersion` JSON property; we use `FullSemVer` instead.
#   - GitVersion 6 emits commits-since-version-source after `+` (ContinuousDelivery
#     style), where v5 ContinuousDeployment fused them into the prerelease with `.`.
#     We convert `+` -> `.` to keep the v5 shape.
#   - GitVersion 6 no longer zero-pads pull-request numbers; we re-pad to 4 digits
#     so existing consumers (NuGet feeds, Docker tags) keep matching.
#
# Inputs:
#   $1 (optional) - "true" if this is a nightly build; suffixes the version with
#                   "-nightly-YYYYMMDD". Pass %Nightly.Build% from TeamCity.
#   $2 (optional) - the branch ref to pass to GitVersion (e.g. refs/pull/119/head
#                   or refs/heads/master). TeamCity checks out PR refs in detached
#                   state, so GitVersion can't infer the branch on its own — pass
#                   %teamcity.build.branch% from TeamCity.

is_nightly="${1:-false}"
target_branch="${2:-}"

format_nuget_version() {
    local version="$1"
    version="${version//+/.}"
    if [[ "$version" =~ ([Pp][Rr]-)([0-9]+) ]]; then
        local prefix="${BASH_REMATCH[1]}"
        local num="${BASH_REMATCH[2]}"
        local match="${BASH_REMATCH[0]}"
        local padded
        printf -v padded '%s%04d' "$prefix" "$((10#$num))"
        version="${version/$match/$padded}"
    fi
    printf '%s' "$version"
}

dotnet tool restore

gitversion_args=(/showvariable FullSemVer)
if [[ -n "$target_branch" ]]; then
    # Strip refs/heads/ and refs/tags/ prefixes; for refs/pull/* keep the `pull/` segment
    # so GitVersion's pull-request regex (^(pull-requests|pull|pr)[/-]) matches.
    case "$target_branch" in
        refs/heads/*) target_branch="${target_branch#refs/heads/}" ;;
        refs/tags/*)  target_branch="${target_branch#refs/tags/}" ;;
        refs/*)       target_branch="${target_branch#refs/}" ;;
    esac
    gitversion_args+=(/b "$target_branch")
fi

full_sem_ver=$(dotnet dotnet-gitversion "${gitversion_args[@]}")
nuget_version=$(format_nuget_version "$full_sem_ver")

if [[ "$is_nightly" == "true" ]]; then
    local_today=$(date +%Y%m%d)
    build_number="${nuget_version}-nightly-${local_today}"
else
    build_number="$nuget_version"
fi

echo "GitVersion FullSemVer: ${full_sem_ver}"
echo "Computed build number: ${build_number}"
echo "##teamcity[buildNumber '${build_number}']"
