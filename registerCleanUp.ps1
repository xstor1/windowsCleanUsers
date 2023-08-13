# Cesta k souboru, který obsahuje čisticí skript
$scriptPath = "C:\scripts\CleanProfiles.ps1"

# Obsah čisticího skriptu
$scriptContent = @"
# Získejte seznam aktuálně přihlášených uživatelů
`$loggedInUsers = Get-WmiObject -Class Win32_ComputerSystem | Select-Object -ExpandProperty UserName

Get-WmiObject Win32_UserProfile | Where-Object {
    `$_ .Special -eq `$_ false -and
    `$_ .LocalPath -notmatch 'C:\\Users\\admin' -and
    `$_ .LocalPath -notmatch 'C:\\Users\\admin1' -and
    `$loggedInUsers -notcontains `$_ .LocalPath.Split('\\')[-1]
} | ForEach-Object {
    Remove-WmiObject `$_
}
"@


# Vytvoření čisticího skriptu
Set-Content -Path $scriptPath -Value $scriptContent

# Vytvoření akce, která spustí váš skript
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-File $scriptPath"

# Nastavení spouštění úkolu jednou za měsíc
$trigger = New-ScheduledTaskTrigger -At '1AM' -RepetitionInterval (New-TimeSpan -Days 30)

# Nastavení, která umožní spuštění úkolu po startu, pokud byl přeskočen
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -DontStopOnIdleEnd -StartWhenAvailable

# Registrace úkolu s těmito nastaveními
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "Clean User Profiles" -Description "Monthly task to clean user profiles" -User "NT AUTHORITY\SYSTEM" -RunLevel Highest -Settings $settings

Write-Host "Task registered successfully."
