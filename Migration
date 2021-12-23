$Logfile = "\\szfk.biz\share1\public\migration\log.log"
Start-Transcript -Append \\szfk.biz\share1\public\migration\log.log
function WriteLog
{
    Param ([string]$LogString)
    $Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
    $LogMessage = "$Stamp ********************************************************************************************* $LogString"
    Add-content $LogFile -value $LogMessage
}

#Get-ADUser -Filter * -SearchBase 'OU=SZFK_new,DC=szfk,DC=acron,DC=ru'
Writelog "connect to srvmail"
WriteLog "Connection to biz"
$User = "kiselevsa@szfk.biz"
$PWord = ConvertTo-SecureString -String "UOqnmnq0" -AsPlainText -Force
$UserCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $PWord
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://srvmail.szfk.biz/PowerShell/ -Authentication Kerberos -Credential $UserCredential
Import-PSSession $Session -DisableNameChecking -AllowClobber
Writelog "Get new user list"
Writelog "New contact"
Writelog "Do forwarding"
Writelog "Start mail export"
Remove-PSSession $Session
Writelog "connect to smb1"
$User = "gokszfk\kiselevadm"
$PWord = ConvertTo-SecureString -String "UOqnmnq9" -AsPlainText -Force
$UserCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $PWord
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://szfk-vm-extsmb1/PowerShell/ -Authentication Kerberos -Credential $UserCredential
Import-PSSession $Session -DisableNameChecking -AllowClobber
Writelog "delete contact"
Writelog "censel forwarding"
Writelog "set servise password"
Get-Content -path \\szfk.biz\share1\PUBLIC\Migration\users.txt |foreach-object {
    $pass = '123qweASD'
    get-aduser $_ | Set-ADAccountPassword -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $pass -Force -Verbose) –PassThru
    $_ +" "+ $pass >> \\szfk.biz\share1\PUBLIC\Migration\NewPWD.txt
} 
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
Remove-PSSession $Session
Stop-Transcript
#>