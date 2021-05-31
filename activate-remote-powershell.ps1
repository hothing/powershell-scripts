Enable-PsRemoting -SkipNetworkProfileCheck -Force
# Can be checked with:
# Get-NetFirewallRule -Name "WINRM-HTTP-In-TCP*"
Set-NetFirewallRule -Name "WINRM-HTTP-In-TCP-PUBLIC" -RemoteAddress Any