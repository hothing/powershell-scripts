
<#PSScriptInfo

.VERSION 1.0

.GUID b59631d7-0dd8-405f-a687-24c66091d892

.AUTHOR user1

.COMPANYNAME 

.COPYRIGHT 

.TAGS 

.LICENSEURI 

.PROJECTURI 

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES

#>

<# 

.DESCRIPTION 
 Change network adapter connection settings : IP address, mask, gateways and DNS servers

.PARAMETER ConnectionName
The connection name assosiated with the network adapter, on which the address settings willbe changed

.PARAMETER Dhcp
Activate the address settings given by DHCP

.PARAMETER Dhcp

.PARAMETER IpAddress

.PARAMETER IpMask

.PARAMETER Gateways

.PARAMETER DNSServers

.INPUTS
*System.String*    The connection name assosiated with the network adapter

.OUTPUTS
None.

#> 
[CmdletBinding()]
Param(
    [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0)][string]$ConnectionName, 
    [Parameter(ParameterSetName='Dynamic', Mandatory=$true)][switch]$Dhcp, 
    [Parameter(ParameterSetName='Static', Mandatory=$true)][string]$IpAddress, 
    [Parameter(ParameterSetName='Static')][string]$IpMask, 
    [Parameter(ParameterSetName='Static')][string[]]$Gateways, 
    [Parameter(ParameterSetName='Static')][string[]]$DNSServers
    )

$nics = Get-WMIObject Win32_NetworkAdapter | ? { ($_.AdapterType -match "Ethernet") }
$nic0 = ($nics | ? { ($_.NetConnectionID -eq $ConnectionName) })
if ($nic0 -ne $null)
{
    
    $NIC = Get-WMIObject Win32_NetworkAdapterConfiguration |? {$_.Index -eq $nic0.DeviceID }    

    if (($IpAddress -ne $null) -and (-not $Dhcp))
    {
        if (($IpMask -eq $null) -or ($IpMask.Length -lt 7)) { 
            $IpMask = "255.255.255.0"
            Write-Warning ("Default IP subnet mask will be used : {0}" -f $IpMask) 
        }
        $r1 = $NIC.EnableStatic($IpAddress, $IpMask)
        if ($r1.Returnvalue -eq 0)
        {
            if (($null -ne $Gateways) -and $Gateways.Count > 0)
            {
                $NIC.SetGateways($Gateways)
            }
            if (($null -ne $DNSServers) -and $DNSServers.Count > 0)
            {
                $NIC.SetDNSServerSearchOrder($DNSServers)
                $NIC.SetDynamicDNSRegistration($false)
            }
        }
        else
        {
            Write-Warning ("IP static address activation is failed [retcode = {0}]" -f $r1.Returnvalue)
        }
    }
    else
    {
        
        $r1 = $NIC.EnableDHCP()
        if ($r1.Returnvalue -eq 0)
        {
            $r2 = $NIC.SetDynamicDNSRegistration($true)
        }
        else
        {
            Write-Warning ("DHCP activation is failed [retcode = {0}]" -f $r1.Returnvalue)
        }        
    }
    # To apply the settings the adapter must be restarted
    $r = $nic0.Disable()
    $r = $nic0.Enable()
}
else
{
    Write-Warning "Network adapter for connection '$ConnectionName' is not found"
    Write-Warning "Existing connections:"
    $nics |  % { Write-Warning ("* {0}" -f $_.NetConnectionID) }
    #$nics |  % { Write-Output ("* {0}" -f $_.NetConnectionID) }
}
