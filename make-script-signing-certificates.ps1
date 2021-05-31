# Make the certificate for the script signing

#$certPSRoot = New-SelfSignedCertificate -Type CodeSigningCert `
#    -Subject "CN=PowerShell Local Certificate Root" `
#    -DnsName 'PsEncryptionCert' `
#    -HashAlgorithm SHA1 `
#    -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.3") `
#    -KeyFriendlyName "PowerShell Remote Sign" 
#   -CertStoreLocation "Cert:\LocalMachine\Root"

$certPSRoot = New-SelfSignedCertificate -Type CodeSigningCert `
    -Subject "CN=PowerShell Local Certificate Root" `
    -DnsName 'www.nowhere.org' `
    -KeyFriendlyName "PowerShell Remote Sign" `
    -CertStoreLocation "Cert:\CurrentUser\Root" 

#########

$certPSUser = New-SelfSignedCertificate -Type CodeSigningCert `
    -Subject "CN=PowerShell User" `
    -KeyFriendlyName "PowerShell Remote Sign" `
    -Signer $certPSRoot `
    -CertStoreLocation "Cert:\CurrentUser\My"