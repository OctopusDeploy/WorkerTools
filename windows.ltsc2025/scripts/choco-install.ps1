param(
    [Parameter(Mandatory = $true)][string]$Package,
    [string]$Version,
    [switch]$AllowEmptyChecksums
)

$chocoArgs = @('install', $Package, '-y', '--no-progress')

# Version is not always needed to be set
if (![string]::IsNullOrEmpty($Version)) { 
    $chocoArgs += @('--version', $Version)
}

if ($AllowEmptyChecksums) { $chocoArgs += '--allow-empty-checksums' }

& choco @chocoArgs
$exitCode = $LASTEXITCODE

Remove-Item -Recurse -Force "$env:TEMP\chocolatey" -ErrorAction Ignore
Get-ChildItem "$env:ChocolateyInstall\lib" -Recurse -Filter *.nupkg | Where-Object Length -gt 10MB | Remove-Item -Force
Remove-Item -Force "$env:windir\Installer\*.msi", "$env:windir\Installer\*.msp" -ErrorAction Ignore
Remove-Item -Recurse -Force "$env:ChocolateyInstall\logs\*" -ErrorAction Ignore

exit $exitCode
