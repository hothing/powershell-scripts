$rawPassword = "Dsc!18052021"
$certFolder = "c:\dsc-conf\keys\"

# Import to the root store so that it is trusted
$mypwd = ConvertTo-SecureString -String $rawPassword -Force -AsPlainText
Import-PfxCertificate -FilePath "$certFolder\DscPrivateKey.pfx" -CertStoreLocation Cert:\LocalMachine\My -Password $mypwd