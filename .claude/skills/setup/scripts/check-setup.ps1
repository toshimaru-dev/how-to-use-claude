<#
.SYNOPSIS
    Check development environment setup status.
    Outputs status for each required tool and provides install commands for missing items.
    Compatible with Windows PowerShell 5.1+.
#>
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Test-CommandExists {
    param([string]$Cmd)
    return ($null -ne (Get-Command $Cmd -ErrorAction SilentlyContinue))
}

function Get-VersionString {
    param([string]$Cmd)
    try {
        $lines = & $Cmd "--version" 2>$null
        $first = $lines | Where-Object { $_ -match '\S' } | Select-Object -First 1
        if ($first) { return $first.Trim() } else { return "" }
    } catch {
        return ""
    }
}

$items = @()

# Node.js
$ok = Test-CommandExists "node"
$items += [PSCustomObject]@{
    Label      = "Node.js"
    Ok         = $ok
    Detail     = if ($ok) { Get-VersionString "node" } else { "NOT INSTALLED" }
    InstallCmd = "winget install -e --id OpenJS.NodeJS.LTS"
    Note       = if (-not $ok) { "Run in PowerShell (Administrator), then restart terminal" } else { "" }
    NeedsAdmin = (-not $ok)
}

# Git
$ok = Test-CommandExists "git"
$items += [PSCustomObject]@{
    Label      = "Git"
    Ok         = $ok
    Detail     = if ($ok) { Get-VersionString "git" } else { "NOT INSTALLED" }
    InstallCmd = "winget install -e --id Git.Git"
    Note       = if (-not $ok) { "Run in PowerShell (Administrator), then restart terminal" } else { "" }
    NeedsAdmin = (-not $ok)
}

# GitHub CLI
$ok = Test-CommandExists "gh"
$items += [PSCustomObject]@{
    Label      = "GitHub CLI"
    Ok         = $ok
    Detail     = if ($ok) { Get-VersionString "gh" } else { "NOT INSTALLED" }
    InstallCmd = "winget install -e --id GitHub.cli"
    Note       = if (-not $ok) { "Run in PowerShell (Administrator), then restart terminal" } else { "" }
    NeedsAdmin = (-not $ok)
}

# VS Code
$ok = Test-CommandExists "code"
$items += [PSCustomObject]@{
    Label      = "VS Code"
    Ok         = $ok
    Detail     = if ($ok) { Get-VersionString "code" } else { "NOT INSTALLED" }
    InstallCmd = "winget install -e --id Microsoft.VisualStudioCode"
    Note       = if (-not $ok) { "Run in PowerShell (Administrator), then restart terminal" } else { "" }
    NeedsAdmin = (-not $ok)
}

# Claude Code
$ok = Test-CommandExists "claude"
$items += [PSCustomObject]@{
    Label      = "Claude Code"
    Ok         = $ok
    Detail     = if ($ok) { Get-VersionString "claude" } else { "NOT INSTALLED" }
    InstallCmd = "npm install -g @anthropic-ai/claude-code"
    Note       = ""
    NeedsAdmin = $false
}

# Codex CLI
$codexOk = Test-CommandExists "codex"
$items += [PSCustomObject]@{
    Label      = "Codex CLI"
    Ok         = $codexOk
    Detail     = if ($codexOk) { Get-VersionString "codex" } else { "NOT INSTALLED" }
    InstallCmd = "npm install -g @openai/codex"
    Note       = ""
    NeedsAdmin = $false
}

# Codex login
$loginOk = $false
$loginDetail = "SKIPPED (Codex CLI not installed)"
if ($codexOk) {
    try {
        $out = (codex login status 2>&1) -join " "
        $loginOk = ($out -match "Logged in")
        $loginDetail = if ($loginOk) { "LOGGED IN (ChatGPT)" } else { "NOT LOGGED IN" }
    } catch {
        $loginDetail = "CHECK FAILED"
    }
}
$items += [PSCustomObject]@{
    Label      = "Codex Login"
    Ok         = $loginOk
    Detail     = $loginDetail
    InstallCmd = "codex login"
    Note       = if ((-not $loginOk) -and $codexOk) { "Browser will open for ChatGPT authentication" } else { "" }
    NeedsAdmin = $false
}

# MCP codex registration - check Claude config files directly
$mcpOk = $false
$mcpDetail = "NOT REGISTERED"
$claudeConfigPaths = @(
    (Join-Path $env:APPDATA "Claude\settings.json"),
    (Join-Path $env:USERPROFILE ".claude\settings.json"),
    (Join-Path $env:USERPROFILE ".claude.json")
)
foreach ($cfgPath in $claudeConfigPaths) {
    if (Test-Path $cfgPath) {
        $cfgContent = Get-Content $cfgPath -Raw -ErrorAction SilentlyContinue
        if ($cfgContent -and ($cfgContent -match '"codex"')) {
            $mcpOk = $true
            $mcpDetail = "REGISTERED"
            break
        }
    }
}
$items += [PSCustomObject]@{
    Label      = "MCP codex"
    Ok         = $mcpOk
    Detail     = $mcpDetail
    InstallCmd = "claude mcp add codex -s user -- codex mcp-server"
    Note       = if (-not $mcpOk) { "Restart Claude Code after registration" } else { "" }
    NeedsAdmin = $false
}

# ── Display results ───────────────────────────────────────
Write-Host ""
Write-Host "========================================"
Write-Host "  Setup Status Check"
Write-Host "========================================"
Write-Host ""

$adminCmds = @()

foreach ($item in $items) {
    if ($item.Ok) {
        Write-Host "[OK] $($item.Label) -- $($item.Detail)"
    } else {
        Write-Host "[NG] $($item.Label) -- $($item.Detail)"
        Write-Host "     Install : $($item.InstallCmd)"
        if ($item.Note) {
            Write-Host "     Note    : $($item.Note)"
        }
        if ($item.NeedsAdmin) {
            $adminCmds += $item.InstallCmd
        }
    }
}

Write-Host ""
Write-Host "----------------------------------------"

$ngCount = ($items | Where-Object { -not $_.Ok }).Count
if ($ngCount -eq 0) {
    Write-Host "  All setup complete!"
} else {
    Write-Host "  Incomplete: $ngCount item(s)"
    if ($adminCmds.Count -gt 0) {
        Write-Host ""
        Write-Host "  [Admin required] Open PowerShell as Administrator and run:"
        foreach ($cmd in $adminCmds) {
            Write-Host "    $cmd"
        }
    }
}
Write-Host "========================================"
Write-Host ""

# JSON output for Claude Code to parse
Write-Host "--- JSON ---"
$items | Select-Object Label, Ok, Detail, InstallCmd, Note, NeedsAdmin | ConvertTo-Json
