$currentUser = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
$isAdministrator = $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
function Main {
    Write-Host "����ȥ�鿨����෭��ҳ"
    Read-Host -Prompt "�������ⰴ���Լ���"
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
        Write-Host "[����] ·�� $targetPath ������" -ForegroundColor Red
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
                Write-Host "[ɨ��] ���ļ� $($_.Name) �з��� $($matchResults.Count) ��ƥ����" -ForegroundColor DarkGray
            }
        }
        catch {
            Write-Host "[����] �޷���ȡ�ļ� $filePath" -ForegroundColor Yellow
        }
    }
    if ($allMatches.Count -gt 0) {
        $lastMatch = $allMatches[-1]
        Write-Host "`n���һ��ƥ����ַ�����" -ForegroundColor Cyan
        Write-Host $lastMatch -ForegroundColor Green
        Set-Clipboard -Value $lastMatch
        Write-Host "`n����Ѹ��Ƶ�������" -ForegroundColor DarkCyan
        Write-Host "`n��������벻Ӱ����������"
    }
    else {
        Write-Host "`nδ�ҵ�����Ҫ����ַ���" -ForegroundColor Yellow
        Write-Host "��������������"
        Write-Host "1. ·���°�����Ч�ļ�"
        Write-Host "2. �ļ����ݰ����� 'https://webstatic.mihoyo.com/hkrpg/event/' ��ͷ���ַ���"
    }
        Read-Host -Prompt "�����ⰴ������"
    exit
}
#bվ���о�ѩ
if ($isAdministrator) { 
    Write-Host "��ǰ�û��ǹ���Ա���Թ���ԱȨ�����С�" -ForegroundColor Green
    Main @args
} else {
    Write-Host "��ǰ�û����ǹ���Ա��δ�Թ���ԱȨ�����С����Թ���Ա������д˽ű���" -ForegroundColor Red
    Read-Host -Prompt "����������Լ���..."
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