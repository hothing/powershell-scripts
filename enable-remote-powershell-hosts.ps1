# 0) fix the network profile: it must be private or domain
Write-Information "The network adapter profile must be a private (or domain)"
# 1) initialize WinRM
winrm qc
# 2) Setup the list of trusted hosts
﻿Set-Item WSMan:\localhost\Client\TrustedHosts -Value *
# 3) enable remoting
﻿Enable-PsRemoting # can be used: -SkipNetworkProfileCheck -Force
# Can be checked with:
# Get-NetFirewallRule -Name "WINRM-HTTP-In-TCP*"
Set-NetFirewallRule -Name "WINRM-HTTP-In-TCP-PUBLIC" -RemoteAddress Any
