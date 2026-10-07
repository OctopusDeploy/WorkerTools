param(
    [Parameter(Mandatory = $true)][string]$Package,
    [Parameter(Mandatory = $true)][string]$Version,
    [switch]$AllowEmptyChecksums
)

$chocoArgs = @('install', $Package, '--version', $Version, '-y', '--no-progress')
if ($AllowEmptyChecksums) { $chocoArgs += '--allow-empty-checksums' }

& choco @chocoArgs
$exitCode = $LASTEXITCODE

Remove-Item -Recurse -Force "$env:TEMP\chocolatey" -ErrorAction Ignore

exit $exitCode
