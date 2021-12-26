

    Writelog "New password"
    Function Generate-Complex-Domain-Password ()
    {
    Add-Type -AssemblyName System.Web
    $requirementsPassed = $false
    do {
        $newPassword=[System.Web.Security.Membership]::GeneratePassword(8,1)
        If ( ($newPassword -cmatch "[A-Z\p{Lu}\s]") `
        -and ($newPassword -cmatch "[a-z\p{Ll}\s]") `
        -and ($newPassword -match "[\d]") `
        -and ($newPassword -match "[^\w]")
        )
        {
            $requirementsPassed=$True
        }
        } While ($requirementsPassed -eq $false)
        return $newPassword
    }
    Clear-Content -Path \\szfk.biz\share1\puBLIC\Migration\NewPWD.txt
    Get-Content -path \\szfk.biz\share1\PUBLIC\Migration\users.txt |foreach-object {
    $pass = Generate-Complex-Domain-Password
    get-aduser $_ | Set-ADAccountPassword -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $pass -Force -Verbose) –PassThru
    get-aduser $_ | set-aduser -ChangePasswordAtLogon $true
    $_ +" "+ $pass >> \\szfk.biz\share1\PUBLIC\Migration\NewPWD.txt
    $_ >> \\szfk.biz\share1\PUBLIC\Migration\readyusers.txt
    } 
    #Clear-Content -Path \\szfk.biz\share1\puBLIC\Migration\users.txt