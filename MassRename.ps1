$Users = (Get-Content -Path \\szfk.biz\share1\PUBLIC\Migration\migration.txt).Split(" ")
$Users

(Get-Content -path \\szfk.biz\share1\PUBLIC\Migration\migration.txt | ForEach-Object{
    [PSCustomObject](($_ -split " ")} -join "`r`n" | ConvertFrom-StringData)
} | Select-Object host, user, patch


Get-Content -path \\szfk.biz\share1\PUBLIC\Migration\migration.txt | ForEach-Object{[PSCustomObject]($_ -split " ") -join "`r`n" | ConvertFrom-StringData}