Configuration EnvironmentVariable_Path
{

    Import-DscResource -ModuleName 'PSDscResources'
    Import-DscResource -ModuleName xTimeZone

    Node localhost
    {

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


EnvironmentVariable_Path -OutputPath $dscFolder

Start-DscConfiguration -Path $dscFolder -Wait -Verbose -Force