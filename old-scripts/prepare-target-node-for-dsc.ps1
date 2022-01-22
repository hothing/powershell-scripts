Install-Module 'PSDscResources' -Scope CurrentUser
Install-Module xSmbShare -Scope CurrentUser

$ss = New-PSSession -ComputerName ASC1 -Credential (Get-Credential)

# Copy the modules
Copy-Item -Path "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\*" -Destination "C:\Program Files\WindowsPowerShell\Modules" -ToSession $ss -Recurse -Force 

# Copy the certificates
$dscFolder = "c:\dsc-conf"
$certFolder = "$dscFolder\keys"
Copy-Item -Path $certFolder -Destination $certFolder -ToSession $ss -Recurse -Force 

# initialize DSC enviroment on the target node
Invoke-Command -Session $ss -ScriptBlock { param($rawPassword, $certFolder)
    Set-ExecutionPolicy RemoteSigned -Scope LocalMachine 
    # Import to the root store so that it is trusted
    $mypwd = ConvertTo-SecureString -String $rawPassword -Force -AsPlainText
    Import-PfxCertificate -FilePath "$certFolder\DscPrivateKey.pfx" -CertStoreLocation Cert:\LocalMachine\My -Password $mypwd
} -ArgumentList "Dsc!18052021", $certFolder

$ss | Remove-PSSession
