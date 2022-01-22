Configuration Server_SharedTempFolder
{
    Import-DscResource -ModuleName ComputerManagementDsc

    Node $AllNodes.ForEach({$_.NodeName})
    {
        LocalConfigurationManager
        {
            CertificateID = $Node.Thumbprint
        }

        SmbShare 'TempShare'
        {
            Name = 'Temp'
            Path = 'C:\Temp'
            Description = 'Data exchange folder'
            ConcurrentUserLimit = 20
            EncryptData = $false
            FolderEnumerationMode = 'AccessBased'
            CachingMode = 'Manual'
            ContinuouslyAvailable = $false
            FullAccess = @("Administrator")
            #ChangeAccess = @('superuser')
            ReadAccess = @('Everyone')
            #NoAccess = @('DeniedUser1')
        }
    }
}

$dscFolder = "c:\dsc-conf"
$certFolder = "$dscFolder\keys"

$thumbprint = (Get-Content -Path "$certFolder\thumbprint.txt" -TotalCount 1)[-1]

$ConfData = @{
    AllNodes = @(    
        @{
            NodeName = "ASS1"
            CertificateFile = "$certFolder\DscPublicKey.cer"
            Thumbprint = $thumbprint 
        },
        @{
            NodeName = "ASS2"
            CertificateFile = "$certFolder\DscPublicKey.cer"
            Thumbprint = $thumbprint 
        }
    )
}

$credSU = (Get-Credential -Message "Taget node account") # use targed node credential for apply configuration

Server_SharedTempFolder -OutputPath $dscFolder -ConfigurationData $ConfData

Start-DscConfiguration -Path $dscFolder -Wait -Verbose -Credential $credSU -Force
