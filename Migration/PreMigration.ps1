Enable-ComputerRestore -Drive "C:\"
VSSAdmin Resize ShadowStorage /For=C: /On=C: /MaxSize=5%
Checkpoint-Computer -Description "Migration"
Get-ComputerRestorePoint
$User = ((Get-ChildItem -Path c:\users\ | Where-Object {$_.name -ne 'Public' -and $_.name -ne 'Administrator' -and $_.name -ne "$env:USERNAME"} | select LastWriteTime, name | Sort-Object LastWriteTime)[-1]).name
Add-Content -Path \\szfk.biz\share1\PUBLIC\Migration\Users.txt -Value $env:COMPUTERNAME
Add-Content -Path \\szfk.biz\share1\PUBLIC\Migration\hosts.txt -Value $User