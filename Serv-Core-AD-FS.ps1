# Install the features
Install-WindowsFeature -Name Windows-Server-Backup -IncludeManagementTools
Install-WindowsFeature -Name DNS -IncludeManagementTools
Install-WindowsFeature -Name Routing -IncludeManagementTools
Install-WindowsFeature -Name DHCP -IncludeManagementTools
Install-WindowsFeature -Name FS-FileServer
Install-WindowsFeature -Name BITS -IncludeManagementTools
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

# Prepare 
## Primary server
Rename-Computer -NewName DC1 -Restart
## Secondary server
Rename-Computer -NewName DC2 -Restart

Get-NetAdapter
Get-NetIPAddress -InterfaceIndex X
New-NetIPAddress -InterfaceIndex 1 -IPAddress 192.168.50.212 -PrefixLengt 24

# Create a domain
Import-Module ADDSDeployment
$cipher =  ConvertTo-SecureString -String "Dsrm!2021" -AsPlainText -Force
## Primary controller
Install-ADDSForest -DomainName “dmz.local” -SafeModeAdministratorPassword $cipher

# Add domain administrtator
New-ADUser -Name “domainadmin” -GivenName Root -Surname Dmz -SamAccountName domainadmin -UserPrincipalName domainadmin@dmz.local 
$user = Get-ADUser domainadmin
# $cipher = Read-Host -AsSecureString
$cipher =  ConvertTo-SecureString -String "Dmz!admin01" -AsPlainText -Force
Set-ADAccountPassword -Identity $user -Reset -NewPassword $cipher
Set-ADUser -Identity $user -Enabled $true
Get-ADGroup “Administrators” | Add-ADGroupMember -Members $user
Get-ADGroup “Domain Admins” | Add-ADGroupMember -Members $user
Enable-ADAccount -Identity domainadmin

# Add domain user #1
$user = New-ADUser -Name “user1” -UserPrincipalName user1@dmz.local 
$cipher = Read-Host -AsSecureString
Set-ADAccountPassword -Identity $user -Reset -NewPassword $cipher
Get-ADGroup “Domain Users” | Add-ADGroupMember -Members $user
Enable-ADAccount -Identity $user

# Add domain user #2
$user = New-ADUser -Name “user2” -UserPrincipalName user2@dmz.local 
$cipher = Read-Host -AsSecureString
Set-ADAccountPassword -Identity $user -Reset -NewPassword $cipher
Get-ADGroup “Domain Users” | Add-ADGroupMember -Members $user
Enable-ADAccount -Identity $user
---------
Add-DhcpServerInDC
#### Add-DhcpServerInDC -DnsName "dmz.local" -IPAddress 192.168.50.212
# Set-up DHCP server for LAN
## Define IP-address range
Add-DhcpServerv4Scope -Name "Dmz Network" -StartRange 192.168.50.32 -EndRange 192.168.50.127 -SubnetMask 255.255.255.0
## Define the DNS servers for clients
Set-DhcpServerv4OptionValue -ScopeId "192.168.50.0" -DnsDomain "dmz.local" -DnsServer ("192.168.50.212","192.168.50.213") -Force
## Define the NTP servers for clients
Set-DhcpServerv4OptionValue -ScopeId "192.168.50.0" -OptionId 42 -Value ("192.168.50.212","192.168.50.213") -Force
## Visual check of the options
Get-DhcpServerv4OptionValue -ScopeId 192.168.50.0 -All

---------
# Enter into domain of the secondary controller
Import-Module ADDSDeployment
$cipher =  ConvertTo-SecureString -String "Dsrm!2021" -AsPlainText -Force
## set address of DNS server of primary controller
Set-DnsClientServerAddress -InterfaceIndex 6 -ServerAddresses "192.168.50.212"
## install a secondary controller and connect to domain
Install-ADDSDomainController -InstallDns -Credential (Get-Credential "DMZ\domainadmin") -DomainName "dmz.local"

## Setup DHCP failover (on DC2 !)
Add-DhcpServerInDC
Add-DhcpServerv4Failover -Name "Dmz-DHCP-Failover" -ComputerName dc1.dmz.local -PartnerServer dc2.dmz.local -ScopeId "192.168.50.0"

-------- CLIENT
# Rename computer with human readable name
Rename-Computer -NewName <HostName> -Restart
# Test the connection to the doman controllers
ping dc1.dmz.local
ping dc2.dmz.local
# Join a domain
Add-Computer -Server dc1.dmz.local -DomainName "dmz.local" -Credential (Get-Credential "domainadmin@dmz.local")
Restart-Computer
# Log-In as local administrator and add a domain user into local group "Remote Desktop Users"
# Now you can log-in as domain user
