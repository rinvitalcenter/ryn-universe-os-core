$ErrorActionPreference = 'Stop'

function Test-ForbiddenGitPath {
    param([string]$Path)

    $normalized = ($Path -replace '\\', '/').Trim()
    $lower = $normalized.ToLowerInvariant()
    $name = [System.IO.Path]::GetFileName($lower)

    if ([string]::IsNullOrWhiteSpace($lower)) { return $false }

    if ($lower.EndsWith('.db')) { return $true }
    if ($lower.EndsWith('.sqlite')) { return $true }
    if ($lower.EndsWith('.sqlite3')) { return $true }
    if ($lower.Contains('-wal')) { return $true }
    if ($lower.Contains('-shm')) { return $true }
    if ($name -eq '.env' -or $lower.Contains('/.env') -or $name.StartsWith('.env.')) { return $true }

    $forbiddenSegments = @(
        'secrets/',
        'tokens/',
        'credentials/',
        'backups/',
        'backup/',
        'snapshots/',
        'exports/private/',
        'local_data/',
        'app_data/',
        'runtime_data/',
        'restore_sandbox/',
        'restore_tmp/',
        'quarantine/',
        'build/',
        '.dart_tool/',
        'ephemeral/',
        '.idea/',
        '.obsidian/workspace',
        '.obsidian/cache'
    )

    foreach ($segment in $forbiddenSegments) {
        if ($lower.Contains($segment)) { return $true }
    }

    if ($name.EndsWith('.iml')) { return $true }

    return $false
}

$stagedFiles = @(git diff --cached --name-only --diff-filter=ACMR)
$trackedFiles = @(git ls-files)

$forbiddenStaged = @($stagedFiles | Where-Object { Test-ForbiddenGitPath $_ })
$forbiddenTracked = @($trackedFiles | Where-Object { Test-ForbiddenGitPath $_ })

if ($forbiddenStaged.Count -gt 0 -or $forbiddenTracked.Count -gt 0) {
    Write-Host 'RYN GIT SAFETY GUARD: FAIL' -ForegroundColor Red
    Write-Host 'Commit blocked because forbidden local/runtime/secret/build files were found.'
    Write-Host 'Only file paths are shown below; file contents and secret values are not read or printed.'

    if ($forbiddenStaged.Count -gt 0) {
        Write-Host ''
        Write-Host 'Forbidden staged files:' -ForegroundColor Red
        $forbiddenStaged | Sort-Object -Unique | ForEach-Object { Write-Host "- $_" }
    }

    if ($forbiddenTracked.Count -gt 0) {
        Write-Host ''
        Write-Host 'Forbidden tracked files:' -ForegroundColor Red
        $forbiddenTracked | Sort-Object -Unique | ForEach-Object { Write-Host "- $_" }
    }

    Write-Host ''
    Write-Host 'Action: unstage/remove these files before committing. Do not commit DB, env, secrets, build outputs, backups, exports, runtime data, restore sandboxes, quarantine folders, IDE local state, or Obsidian machine-local files.'
    exit 1
}

Write-Host 'RYN GIT SAFETY GUARD: PASS'
Write-Host 'No forbidden staged or tracked files detected.'
exit 0
