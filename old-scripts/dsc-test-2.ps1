Configuration EnvironmentVariable_Path
{
    param(
        [Parameter(Mandatory)]
        [PSCredential]$MyCredential
    )


    Import-DscResource -ModuleName 'PSDscResources'

    Node $AllNodes.ForEach({$_.NodeName})
    {
        Environment CreatePathEnvironmentVariable
        {
            Name = 'TestPathEnvironmentVariable'
            Value = 'TestValue'
            Ensure = 'Present'
            Path = $true     
            # Credential  = $MyCredential       
        }

    }
}

$dscFolder = "c:\dsc-conf"
$certFolder = "$dscFolder\keys"

$ConfData = @{
    AllNodes = @(    
        @{
            NodeName = "ASC1"
            CertificateFile = "$certFolder\DscPublicKey.cer"
            Thumbprint = "8487A6FA7E69A62405F1762D8A7F8DD6E6405844"
        }
    )
}

$credSU = (Get-Credential -Message "Taget node account") # use targed node credential for apply configuration

EnvironmentVariable_Path -OutputPath $dscFolder -MyCredential $credSU -ConfigurationData $ConfData

Start-DscConfiguration -Path $dscFolder -Wait -Verbose -Credential $credSU -Force