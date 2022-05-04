Enable-ComputerRestore -Drive "C:\"
VSSAdmin Resize ShadowStorage /For=C: /On=C: /MaxSize=5%
Checkpoint-Computer -Description "Migration"
Get-ComputerRestorePoint
$User = ((Get-ChildItem -Path c:\users\ | Where-Object { $_.name -ne 'Public' -and $_.name -ne 'Administrator' -and $_.name -ne "$env:USERNAME" } | select LastWriteTime, name | Sort-Object LastWriteTime)[-1]).name
Add-Content -Path \\share\Users.txt -Value $env:COMPUTERNAME
Add-Content -Path \\share\hosts.txt -Value $User