$rawPassword = "Dsc!18052021"
$certFolder = "c:\temp\"

# note: These steps need to be performed in an Administrator PowerShell session
$cert = New-SelfSignedCertificate -Type DocumentEncryptionCertLegacyCsp -DnsName 'DscEncryptionCert' -HashAlgorithm SHA256
# export the private key certificate
$mypwd = ConvertTo-SecureString -String $rawPassword -Force -AsPlainText
$cert | Export-PfxCertificate -FilePath "$certFolder\DscPrivateKey.pfx" -Password $mypwd -Force
# remove the private key certificate from the node but keep the public key certificate
$cert | Export-Certificate -FilePath "$certFolder\DscPublicKey.cer" -Force
$cert | Remove-Item -Force
Import-Certificate -FilePath "$certFolder\DscPublicKey.cer" -CertStoreLocation Cert:\LocalMachine\My