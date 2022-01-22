
$targetNode = "ASC1"

$dscFolder = "c:\dsc-conf" # DSC configurations store
$certFolder = "$dscFolder\keys" # DSC certificates store

# the password used for the certificates transfer (.psx file)
$certPassword = "Dsc!18052021"

$targetNode | % {
    $ss = New-PSSession -ComputerName $_ -Credential (Get-Credential)
    if ($ss -ne $null) {
        # Copy the certificates
        Invoke-Command -Session $ss -ScriptBlock { param($certFolder)
            if (-not (Test-Path -Path $certFolder)) { md $certFolder -Force -Verbose }
            else { Write-Verbose "The certificates folder exist" }
        } -ArgumentList $certFolder
        Copy-Item -Path "$certFolder\*" -Destination $certFolder -ToSession $ss -Recurse -Force

        # initialize DSC enviroment on the target node
        Invoke-Command -Session $ss -ScriptBlock { param($rawPassword, $certFolder)
            Set-ExecutionPolicy RemoteSigned -Scope LocalMachine 
            # Import to the root store so that it is trusted
            $mypwd = ConvertTo-SecureString -String $rawPassword -Force -AsPlainText
            Import-PfxCertificate -FilePath "$certFolder\DscPrivateKey.pfx" -CertStoreLocation Cert:\LocalMachine\My -Password $mypwd
        } -ArgumentList $certPassword, $certFolder
        $ss | Remove-PSSession
    }
}

