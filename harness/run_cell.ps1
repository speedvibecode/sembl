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
$sw = [System.Diagnostics.Stopwatch]::StartNew()

switch ($Kind) {
  'gemini3pro'   { & gemini --skip-trust -y -m gemini-3-pro-preview   -p $prompt 2>&1 | Out-Null }
  'gemini3flash' { & gemini --skip-trust -y -m gemini-3-flash-preview -p $prompt 2>&1 | Out-Null }
  'codex54'      { $prompt | codex exec -m gpt-5.4 -c model_reasoning_effort="medium" -C $Worktree -s workspace-write --skip-git-repo-check --color never - 2>&1 | Out-Null }
  'codex55xh'    { $prompt | codex exec -m gpt-5.5 -c model_reasoning_effort="xhigh"  -C $Worktree -s workspace-write --skip-git-repo-check --color never - 2>&1 | Out-Null }
  default        { "unknown kind $Kind"; exit 2 }
}
$secs = [math]::Round($sw.Elapsed.TotalSeconds)

$py = 'C:\Users\totla\Downloads\sembl\.venv\Scripts\python.exe'
$score = 'C:\Users\totla\Downloads\sembl\harness\score_run.py'
$args = @('--repo', $Worktree, '--base', $Base, '--expected', $Expected, '--label', $Label,
          '--task', $Task, '--arm', $Arm, '--seconds', $secs, '--out', $Out)
if ($Arm -eq 'sembl' -and $Wo) { $args += @('--wo', $Wo) }
& $py $score @args | Out-Null
"DONE $Label ($secs s) -> changed: $((git diff --name-only $Base) -join ', ')"
