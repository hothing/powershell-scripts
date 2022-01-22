$targetNode = "ASC1", "ASC2"

$credSU = (Get-Credential -Message "Administrative account for the target nodes")
$targetNode | % {
    # Enable a Remote desktop service
     $ss = New-PSSession -ComputerName $_ -Credential $credSU
     Invoke-Command -Session $ss -ScriptBlock {
        sp -path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\' -name 'fDenyTSConnections' -value 0
        Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
    }
    $ss | Remove-PSSession
}