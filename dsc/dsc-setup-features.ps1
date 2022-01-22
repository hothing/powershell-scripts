Configuration EnvironmentVariable_Path
{
    param(
        [Parameter(Mandatory)]
        [PSCredential]$MyCredential
    )


    Import-DscResource -ModuleName 'PSDscResources'
    Import-DscResource -ModuleName xTimeZone

    Node $AllNodes.ForEach({$_.NodeName})
    {
        LocalConfigurationManager
        {
            #CertificateID = "8487A6FA7E69A62405F1762D8A7F8DD6E6405844"
            CertificateID = $Node.Thumbprint
        }

        xTimeZone TimeZoneExample
        {
            TimeZone = 'Russian Standard Time'
            IsSingleInstance = 'Yes'
        }

        WindowsFeatureSet WinCC_SysFeatures
        {
            Name = @("NET-Framework-Core", "MSMQ-Server")
            Ensure = "Present"
            IncludeAllSubFeature = $true
        }
    }
}

$dscFolder = "c:\dsc-conf"
$certFolder = "$dscFolder\keys"

$thumbprint = (Get-Content -Path "$certFolder\thumbprint.txt" -TotalCount 1)[-1]

$ConfData = @{
    AllNodes = @(    
        @{
            NodeName = "ASC1"
            CertificateFile = "$certFolder\DscPublicKey.cer"
            Thumbprint = $thumbprint 
        },
        @{
            NodeName = "ASC2"
            CertificateFile = "$certFolder\DscPublicKey.cer"
            Thumbprint = $thumbprint 
        }
    )
}

$credSU = (Get-Credential -Message "Taget node account") # use targed node credential for apply configuration

EnvironmentVariable_Path -OutputPath $dscFolder -MyCredential $credSU -ConfigurationData $ConfData

Start-DscConfiguration -Path $dscFolder -Wait -Verbose -Credential $credSU -Force