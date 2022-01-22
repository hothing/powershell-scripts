# 

Configuration MetaConfiguration
{
    # Note that this cannot be "localhost", it must be the actual computer name.
    Node $env:COMPUTERNAME
    {
        LocalConfigurationManager
        {
            CertificateID = "8487A6FA7E69A62405F1762D8A7F8DD6E6405844"
        }
    }
}
 
# Create a MetaConfiguration\TargetServer.meta.mof file and apply it to this computer:
MetaConfiguration -OutputPath "C:\dsc-conf"

Set-DscLocalConfigurationManager "C:\dsc-conf" -Verbose