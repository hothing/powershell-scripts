sp -path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\' -name 'fDenyTSConnections' -value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"