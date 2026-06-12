param(
  [Parameter(Mandatory)] [string]$Worktree,   # isolated checkout at pinned base
  [Parameter(Mandatory)] [string]$Kind,       # gemini3pro|gemini3flash|codex54|codex55xh
  [Parameter(Mandatory)] [string]$Arm,        # raw|sembl
  [Parameter(Mandatory)] [string]$Label,      # e.g. raw-gemini3pro
  [Parameter(Mandatory)] [string]$PromptFile, # raw-prompt or executor-prompt
  [Parameter(Mandatory)] [string]$Base,       # pinned base ref
  [Parameter(Mandatory)] [string]$Expected,   # expected-scope.json
  [Parameter(Mandatory)] [string]$Task,       # e.g. zod-001
  [string]$Wo = "",                           # work-order.json (sembl arm)
  [Parameter(Mandatory)] [string]$Out         # matrix.jsonl
)
$ErrorActionPreference = 'Continue'
$env:GEMINI_CLI_TRUST_WORKSPACE = 'true'
$prompt = Get-Content $PromptFile -Raw
Set-Location $Worktree
git reset --hard -q $Base; git clean -fdq 2>$null
$logDir = Join-Path (Split-Path $Out -Parent) 'logs'
New-Item -ItemType Directory -Force $logDir | Out-Null
$log = Join-Path $logDir "$Label.log"
$sw = [System.Diagnostics.Stopwatch]::StartNew()

# Executor stdout/stderr goes to a per-cell log: codex (and some others)
# report token usage there, and silent failures (auth, usage limits) are
# invisible without it — the first codex54 cell "passed" in 16s on a quota
# error that Out-Null swallowed.
switch ($Kind) {
  'gemini3pro'   { & gemini --skip-trust -y -m gemini-3-pro-preview   -p $prompt 2>&1 | Out-File -Encoding utf8 $log }
  'gemini3flash' { & gemini --skip-trust -y -m gemini-3-flash-preview -p $prompt 2>&1 | Out-File -Encoding utf8 $log }
  'codex54'      { $prompt | codex exec -m gpt-5.4 -c model_reasoning_effort="medium" -C $Worktree -s workspace-write --skip-git-repo-check --color never - 2>&1 | Out-File -Encoding utf8 $log }
  'codex55xh'    { $prompt | codex exec -m gpt-5.5 -c model_reasoning_effort="xhigh"  -C $Worktree -s workspace-write --skip-git-repo-check --color never - 2>&1 | Out-File -Encoding utf8 $log }
  'minimax'      { & opencode run $prompt -m tokenrouter/MiniMax-M3 2>&1 | Out-File -Encoding utf8 $log }
  'nvidia'       { & opencode run $prompt -m nvidia/moonshotai/kimi-k2-instruct 2>&1 | Out-File -Encoding utf8 $log }
  'qwenlocal'    { & opencode run $prompt -m ollama/qwen2.5-coder:7b 2>&1 | Out-File -Encoding utf8 $log }
  default        { "unknown kind $Kind"; exit 2 }
}
$secs = [math]::Round($sw.Elapsed.TotalSeconds)

# Token usage where the CLI reports it (codex: "tokens used: 12,345").
$tokens = 0
$logText = if (Test-Path $log) { Get-Content $log -Raw } else { '' }
if ($logText -match 'tokens used:?\s+([\d,]+)') { $tokens = [int]($Matches[1] -replace ',', '') }
if ($logText -match 'usage limit|rate limit|AuthorizationRequired|quota') {
  "WARN ${Label}: limit/auth marker in executor log ($log)"
}

$py = 'C:\Users\totla\Downloads\sembl\.venv\Scripts\python.exe'
$score = 'C:\Users\totla\Downloads\sembl\harness\score_run.py'
$args = @('--repo', $Worktree, '--base', $Base, '--expected', $Expected, '--label', $Label,
          '--task', $Task, '--arm', $Arm, '--seconds', $secs, '--tokens', $tokens, '--out', $Out)
if ($Arm -eq 'sembl' -and $Wo) { $args += @('--wo', $Wo) }
& $py $score @args | Out-Null
"DONE $Label ($secs s, $tokens tok) -> changed: $((git diff --name-only $Base) -join ', ')"
