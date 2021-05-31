$targetNode = "ASC1", "ASC2"

$scripts = "enable-rdp.ps1", "enable-features.ps1"
#$scripts = @("enable-features.ps1")

$wp = ($MyInvocation.MyCommand.Source | Split-Path -Parent)

$credSU = (Get-Credential -Message "Administrative account for the target nodes")
$scripts | % { Invoke-Command -ComputerName $targetNode -Credential $credSU -FilePath "$wp\$_" }