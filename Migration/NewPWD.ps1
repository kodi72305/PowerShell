Writelog "New password"
Function Generate-Complex-Domain-Password () {
    Add-Type -AssemblyName System.Web
    $requirementsPassed = $false
    do {
        $newPassword = [System.Web.Security.Membership]::GeneratePassword(8, 1)
        If ( ($newPassword -cmatch "[A-Z\p{Lu}\s]") `
                -and ($newPassword -cmatch "[a-z\p{Ll}\s]") `
                -and ($newPassword -match "[\d]") `
                -and ($newPassword -match "[^\w]")
        ) {
            $requirementsPassed = $True
        }
    } While ($requirementsPassed -eq $false)
    return $newPassword
}
Clear-Content -Path \\share\NewPWD.txt
Get-Content -path \\share\users.txt | foreach-object {
    $pass = Generate-Complex-Domain-Password
    get-aduser $_ | Set-ADAccountPassword -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $pass -Force -Verbose) –PassThru
    get-aduser $_ | set-aduser -ChangePasswordAtLogon $true
    $_ + " " + $pass >> \\share\NewPWD.txt
    $_ >> \\share\readyusers.txt
} 
Clear-Content -Path \\share\users.txt