$Users = (Get-Content -Path \\share\migration.txt).Split(" ")
$Users

(Get-Content -path \\share\migration.txt | ForEach-Object { [PSCustomObject](($_ -split " ") -join "`r`n" | ConvertFrom-StringData) } | Select-Object host, user, patch
Get-Content -path \\share\migration.txt | ForEach-Object { [PSCustomObject]($_ -split " ") -join "`r`n" | ConvertFrom-StringData }