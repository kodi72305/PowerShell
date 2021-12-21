clear
echo "biz"
$User = "kiselevsa@szfk.biz"
$PWord = ConvertTo-SecureString -String "UOqnmnq0" -AsPlainText -Force
$UserCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $PWord
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://srvmail.szfk.biz/PowerShell/ -Authentication Kerberos -Credential $UserCredential
Import-PSSession $Session -DisableNameChecking -AllowClobber

Remove-PSSession $Session




echo "acron"
$User = "gokszfk\kiselevadm"
$PWord = ConvertTo-SecureString -String "UOqnmnq9" -AsPlainText -Force
$UserCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $PWord
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://szfk-vm-extsmb1/PowerShell/ -Authentication Kerberos -Credential $UserCredential
Import-PSSession $Session -DisableNameChecking -AllowClobber

