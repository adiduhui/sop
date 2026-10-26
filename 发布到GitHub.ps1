# ============================================================
#  把「考研 SOP 作战台」发布到 GitHub
#  用法：右键本文件 → 使用 PowerShell 运行
#  认证：会弹出浏览器让你登录 GitHub（不会把密码交给任何脚本）
# ============================================================

$ErrorActionPreference = 'Continue'
Set-Location -LiteralPath $PSScriptRoot

Write-Host ""
Write-Host "=== 考研 SOP 作战台 · 一键发布 ===" -ForegroundColor Cyan
Write-Host ""

# ---------- 0. 前置检查 ----------
if (-not (Test-Path '.\index.html')) {
    Write-Host "[X] 当前目录找不到 index.html，请把本脚本放在 sop 文件夹里运行。" -ForegroundColor Red
    Read-Host "按回车退出"; exit 1
}
$git = Get-Command git -ErrorAction SilentlyContinue
if (-not $git) {
    Write-Host "[X] 没检测到 git，请先安装 Git for Windows。" -ForegroundColor Red
    Read-Host "按回车退出"; exit 1
}

# ---------- 1. 收集身份 ----------
Write-Host "请先在网页上建好一个【空的公开仓库】，名字必须是：sop" -ForegroundColor Yellow
Write-Host "  地址：https://github.com/new  →  Repository name 填 sop  →  Public  →  不要勾任何初始化文件  →  Create"
Write-Host ""
$user = Read-Host "你的 GitHub 用户名（例如 zhangsan）"
if ([string]::IsNullOrWhiteSpace($user)) { Write-Host "[X] 用户名不能为空" -ForegroundColor Red; Read-Host; exit 1 }
$email = Read-Host "你的 GitHub 邮箱（直接回车则用 $user@users.noreply.github.com）"
if ([string]::IsNullOrWhiteSpace($email)) { $email = "$user@users.noreply.github.com" }

# ---------- 2. 初始化仓库 ----------
Write-Host ""
Write-Host "[1/4] 初始化本地仓库..." -ForegroundColor Cyan
if (-not (Test-Path '.\.git')) {
    git init -b main | Out-Null
    if ($LASTEXITCODE -ne 0) { git init | Out-Null; git branch -M main | Out-Null }
} else {
    Write-Host "      已存在 .git，沿用"
}
git config user.name  $user
git config user.email $email

# ---------- 3. 提交 ----------
Write-Host "[2/4] 暂存并提交..." -ForegroundColor Cyan
git add -A
$hasCommit = (git rev-parse --verify HEAD 2>$null)
if ($LASTEXITCODE -ne 0 -or -not $hasCommit) {
    git commit -m "init: 考研 S.O.P. 作战台" | Out-Null
} else {
    git commit -m ("update: " + (Get-Date -Format 'yyyy-MM-dd HH:mm')) | Out-Null
}
if ($LASTEXITCODE -ne 0) { Write-Host "      （没有新改动，跳过提交）" -ForegroundColor DarkGray }

# ---------- 4. 关联远程并推送 ----------
Write-Host "[3/4] 关联远程仓库..." -ForegroundColor Cyan
git remote remove origin 2>$null | Out-Null
git remote add origin "https://github.com/$user/sop.git"

Write-Host "[4/4] 推送到 GitHub（接下来会弹浏览器，请用你的账号登录并授权）..." -ForegroundColor Cyan
Write-Host ""
git push -u origin main

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "[!] 推送失败。常见原因：" -ForegroundColor Yellow
    Write-Host "    1) 仓库还没建，或名字不是 sop    → 去 https://github.com/new 建一个空的 sop"
    Write-Host "    2) 用户名填错                     → 重跑本脚本"
    Write-Host "    3) 授权窗口被关掉了               → 重跑本脚本，这次记得点授权"
    Write-Host "    4) 建仓库时勾了 README/LICENSE    → 会冲突。最省事：把仓库删了重建成完全空的，再重跑"
    Read-Host "按回车退出"; exit 1
}

Write-Host ""
Write-Host "[OK] 推送成功！" -ForegroundColor Green
Write-Host ""
Write-Host "接下来（只需要做一次）：" -ForegroundColor Cyan
Write-Host "  1. 打开 https://github.com/$user/sop/settings/pages"
Write-Host "  2. Source 选 'Deploy from a branch'"
Write-Host "  3. Branch 选 main ，目录选 / (root) ，点 Save"
Write-Host "  4. 等 1~2 分钟，访问： https://$user.github.io/sop/"
Write-Host "  5. iPad 用 Safari 打开该网址 → 分享 → 添加到主屏幕"
Write-Host ""
Read-Host "按回车关闭"
