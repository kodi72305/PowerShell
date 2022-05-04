$server1 = read-host
$server2 = read-host
$share = read-host
$Logfile = "$share\log.log"
$Logfile
Start-Transcript -Append \\$share\log.log
function WriteLog {
    Param ([string]$LogString)
    $Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
    $LogMessage = "$Stamp ********************************************************************************************* $LogString"
    Add-content $LogFile -value $LogMessage
}
5
$UserCredentialBiz = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://$server1/PowerShell/ -Authentication Kerberos -Credential $UserCredentialBiz -ErrorAction Stop
Remove-PSSession $Session

$UserCredentialRu = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://$server2/PowerShell/ -Authentication Kerberos -Credential $UserCredentialRu -ErrorAction Stop
Remove-PSSession $Session

Writelog "Check user list"
Get-Content -Path \\$share\users.txt | ForEach-Object {
    try {
        get-aduser -Identity $_
        WriteLog "Check Email"
        try {
            Get-Mailbox -Identity $_.SamAccountName
        }
        catch [Microsoft.Exchange.Configuration.Tasks.ManagementObjectNotFoundException] {
            Enable-Mailbox -Identity $_.SamAccountName
            
        }
    }
    catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
        Add-Content -Path \\$share\ErrorUsers.txt -Value $_
    }
}

Get-Content -Path \\$share\users.txt | get-aduser | ForEach-Object {
    WriteLog "Check Use mailbox"
    if ((Get-MailboxStatistics -Identity $_.SamAccountName | select LastLogonTime) -ne $null) {
        WriteLog 'Mailbox $_.SamAccountName already use'
        continue
    }
    
    Writelog "connect to srvmail"
    $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://$server1/PowerShell/ -Authentication Kerberos -Credential $UserCredentialBiz -ErrorAction Stop
    Import-PSSession $Session -DisableNameChecking -AllowClobber

    Writelog "New contact"
    New-MailContact -ExternalEmailAddress $_.EmailAddress -Name $_.name

    Writelog "Do forwarding"
    Set-Mailbox -ForwardingAddress ($_.EmailAddress) -DeliverToMailboxAndForward:$true

    Writelog "Start mail export"
    New-MailboxExportRequest -Mailbox $_.SamAccountName -FilePath
    
    WriteLog "Send test message"
    Send-MailMessage -From test@szfk.biz -To ($_.SamAccountName + '@szfk.biz')  -SmtpServer $server2.szfk.acron.ru -Body 'Send from biz' -Subject "test message from szfk.biz"

    Remove-PSSession $Session

    Writelog "connect to smb1"
    $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://$server2/PowerShell/ -Authentication Kerberos -Credential $UserCredentialRu -ErrorAction Stop
    Import-PSSession $Session -DisableNameChecking -AllowClobber

    WriteLog "Correct Email and Aliace"
    if ((Get-Mailbox -identity $_.SamAccountName | Select-Object mailbox) -like '*1*') {
        Set-Mailbox -identity $_ -PrimarySmtpAddress ($_.PrimarySmtpAddress -replace '1') -EmailAddressPolicyEnabled:$false
        Set-Mailbox -identity $_ -EmailAddresses ($_.EmailAddresses -replace '1') -alias ($_.alias -replace '1') -EmailAddressPolicyEnabled $false
    }
    Writelog "delete contact"
    Remove-MailContact -Identity ($_.SamAccountName + '@szfk.biz') -Confirm:$false

    Writelog "censel forwarding"
    set-mailbox -Identity $_.SamAccountName -ForwardingAddress:$null -ForwardingSmtpAddress:$null -DeliverToMailboxAndForward:$false

    WriteLog "Check Group"
    $user = $_.SamAccountName
    Get-ADPrincipalGroupMembership -Identity $_.SamAccountName | select name | foreach {
        try {
            Add-ADGroupMember -Identity $_ -Members $user
        }
        catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
            WriteLog 'Group $_ does not exist' 
            Add-Content -Path \\$share\ErrorUsers.txt -Value $_
        }
        catch [Microsoft.ActiveDirectory.Management.ADException] {
        }

    }

    Writelog "set servise password"
    $pass = '123qweASD'
    get-aduser $_ | Set-ADAccountPassword -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $pass -Force -Verbose) –PassThru
    $_ + " " + $pass >> \\$share\NewPWD.txt
    
    WriteLog "Send test message RU"
    Send-MailMessage -From test@szfk.ru -To $_.EmailAddresses  -SmtpServer $server2.szfk.acron.ru -Body 'Send from ru' -Subject "test message frome szfk.ru"
    Remove-PSSession $Session
}
Stop-Transcript
