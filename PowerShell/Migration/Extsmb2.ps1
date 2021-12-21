clear
# $UserCredential = Get-Credential -UserName kiselevadm@szfk.ru
$User = "gokszfk\kiselevADM"
$PWord = ConvertTo-SecureString -String "UOqnmnq9" -AsPlainText -Force
$UserCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $PWord
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://szfk-vm-extsmb2/PowerShell/ -Authentication Kerberos -Credential $UserCredential 
Import-PSSession $Session -DisableNameCheckin -AllowClobber







Remove-PSSession $Session