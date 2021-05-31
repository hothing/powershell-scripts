$targetNode = "ASC1", "ASC2"

$credSU = (Get-Credential -Message "Administrative account for the target nodes")

Invoke-Command -ComputerName $targetNode -Credential $credSU -ScriptBlock {
        sp -path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\' -name 'fDenyTSConnections' -value 0
        Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
}