$rawPassword = "Dsc!18052021"

$dscFolder = "c:\dsc-conf"
$certFolder = "$dscFolder\keys"

if (((dir Cert:\LocalMachine\My) | where-object subject -Match "CN=DscEncryptionCert") -eq $null) { 
    if (-not (Test-Path $certFolder)) { md $certFolder -Force -Verbose }
    # note: These steps need to be performed in an Administrator PowerShell session
    $cert = New-SelfSignedCertificate -Type DocumentEncryptionCertLegacyCsp -DnsName 'DscEncryptionCert' -HashAlgorithm SHA256 -KeyFriendlyName "DSC Remote Sign"
    # export the private key certificate
    $mypwd = ConvertTo-SecureString -String $rawPassword -Force -AsPlainText
    $cert | Export-PfxCertificate -FilePath "$certFolder\DscPrivateKey.pfx" -Password $mypwd -Force
    # remove the private key certificate from the node but keep the public key certificate
    $cert | Export-Certificate -FilePath "$certFolder\DscPublicKey.cer" -Force

    Set-Content -Path "$certFolder\thumbprint.txt" -Value $cert.Thumbprint

    $cert | Remove-Item -Force
    Import-Certificate -FilePath "$certFolder\DscPublicKey.cer" -CertStoreLocation Cert:\LocalMachine\My
} 
else
{
    Write-Host "DSC certificates are already installed"
}
