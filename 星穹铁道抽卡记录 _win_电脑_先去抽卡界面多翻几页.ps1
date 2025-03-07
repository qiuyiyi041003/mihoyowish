$currentUser = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
$isAdministrator = $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
function Main {
    Write-Host "请先去抽卡界面多翻几页"
    Read-Host -Prompt "按下任意按键以继续"
    Add-Type -AssemblyName System.Web
    $logLocation = "%userprofile%\AppData\LocalLow\miHoYo\$([char]0x5D29)$([char]0x574F)$([char]0xFF1A)$([char]0x661F)$([char]0x7A79)$([char]0x94C1)$([char]0x9053)\Player.log"
    Write-Host "$logLocationChina"
    $reg = $args[0]
    $apiHost = "public-operation-hk4e-sg.hoyoverse.com" 
    Write-Host "Using China cache location"
    $apiHost = "public-operation-hk4e.mihoyo.com"
    $tmps = $env:TEMP + '\pm.ps1'
    if ([System.IO.File]::Exists($tmps)) {
        Remove-Item $tmps
    }
    $path = [System.Environment]::ExpandEnvironmentVariables($logLocation);
    Write-Host "$path"
    $logs = Get-Content -Path $path -Encoding utf8
    Write-Host "`n"
    $m = $logs -match "(?m).:/.+(StarRail_Data)"
    Write-Host "$m"
    $m[0] -match "(.:/.+(StarRail_Data))" >$null
    if ($matches.Length -eq 0) {
        Write-Host "Cannot find the wish history url! Make sure to open the wish history first!" -ForegroundColor Red
    return
    }
    $gamedir = $matches[1]
    Write-Host "$gamedir"
    $absoluteWebcachePath = Resolve-Path (Join-Path $gamedir "webCaches/")
    Write-Host "$absoluteWebcachePath"
    $cacheVerPath = Get-Item (Get-ChildItem -Path $absoluteWebcachePath | Sort-Object LastWriteTime -Descending | Select-Object -First 1).FullName
    Write-Host "$cacheVerPath"
    $cachefile = Resolve-Path "$cacheVerPath/Cache/Cache_Data/data_2"
    Write-Host "$cachefile"
    $tmpfile = "$env:TEMP/ch_data_1" 
    Copy-Item $cachefile -Destination $tmpfile
    $targetPath = "$env:TEMP/ch_data_1"
    if (-not (Test-Path $targetPath)) {
        Write-Host "[错误] 路径 $targetPath 不存在" -ForegroundColor Red
        exit
    }
    $urlPart = 'https://webstatic.mihoyo.com/hkrpg/event/'
    $escapedUrlPart = [regex]::Escape($urlPart)
    $pattern = "$escapedUrlPart[^ ]*"
    $allMatches = @()
    Get-ChildItem -Path $targetPath -Recurse -File | ForEach-Object {
        $filePath = $_.FullName
        try {
            $encoding = [System.Text.Encoding]::UTF8
            $reader = [System.IO.StreamReader]::new($filePath)
            $content = $reader.ReadToEnd()
            $reader.Close()
            $matchResults = [regex]::Matches($content, "(?s)$pattern")
            if ($matchResults.Count -gt 0) {
                $allMatches += $matchResults.Value
                Write-Host "[扫描] 在文件 $($_.Name) 中发现 $($matchResults.Count) 个匹配项" -ForegroundColor DarkGray
            }
        }
        catch {
            Write-Host "[警告] 无法读取文件 $filePath" -ForegroundColor Yellow
        }
    }
    if ($allMatches.Count -gt 0) {
        $lastMatch = $allMatches[-1]
        Write-Host "`n最后一个匹配的字符串：" -ForegroundColor Cyan
        Write-Host $lastMatch -ForegroundColor Green
        Set-Clipboard -Value $lastMatch
        Write-Host "`n结果已复制到剪贴板" -ForegroundColor DarkCyan
        Write-Host "`n后面的乱码不影响正常复制"
    }
    else {
        Write-Host "`n未找到符合要求的字符串" -ForegroundColor Yellow
        Write-Host "请检查以下条件："
        Write-Host "1. 路径下包含有效文件"
        Write-Host "2. 文件内容包含以 'https://webstatic.mihoyo.com/hkrpg/event/' 开头的字符串"
    }
        Read-Host -Prompt "按任意按键结束"
    exit
}
#b站月中聚雪
if ($isAdministrator) { 
    Write-Host "当前用户是管理员，以管理员权限运行。" -ForegroundColor Green
    Main @args
} else {
    Write-Host "当前用户不是管理员，未以管理员权限运行。请以管理员身份运行此脚本。" -ForegroundColor Red
    Read-Host -Prompt "按下任意键以继续..."
    $scriptPath = "`"$($MyInvocation.MyCommand.Definition)`""
    $baseArgs = @(
        "-NoExit",
        "-File",
        $scriptPath
    )
    $allArgs = $baseArgs + $args.GetEnumerator()
    Start-Process powershell -Verb RunAs -ArgumentList $allArgs
    exit
}