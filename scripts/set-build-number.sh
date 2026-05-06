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

is_nightly="${1:-false}"

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

full_sem_ver=$(dotnet dotnet-gitversion /output json | jq -r '.FullSemVer')
nuget_version=$(format_nuget_version "$full_sem_ver")

if [[ "$is_nightly" == "true" ]]; then
    local_today=$(date +%Y%m%d)
    build_number="${nuget_version}-nightly-${local_today}"
else
    # Populate GitVersion_* env vars for downstream TeamCity steps.
    dotnet dotnet-gitversion /output buildserver
    build_number="$nuget_version"
fi

echo "##teamcity[buildNumber '${build_number}']"
