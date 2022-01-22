
$dscFolder = "c:\dsc-conf" # DSC configurations store
$certFolder = "$dscFolder\keys" # DSC certificates store

# the password used for the certificates transfer (.psx file)
$certPassword = "Dsc!18052021"

#install required modules
Install-Module 'PSDscResources'
Install-Module xSmbShare

# Copy the modules
$modPath = "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\*"
$modPath = ($env:PSModulePath -split ";" | % {if (Test-Path $_ ) { dir $_ } } | where-object Name -match 'PSDscResources' ).FullName

if ($modPath -ne $null) {
    $ss = New-PSSession -ComputerName ASC1 -Credential (Get-Credential)
    Copy-Item -Path $modPath -Destination "C:\Program Files\WindowsPowerShell\Modules" -ToSession $ss -Recurse -Force 

    # Copy the certificates
    
    Copy-Item -Path $certFolder -Destination $certFolder -ToSession $ss -Recurse -Force 

    # initialize DSC enviroment on the target node
    Invoke-Command -Session $ss -ScriptBlock { param($rawPassword, $certFolder)
        Set-ExecutionPolicy RemoteSigned -Scope LocalMachine 
        # Import to the root store so that it is trusted
        $mypwd = ConvertTo-SecureString -String $rawPassword -Force -AsPlainText
        Import-PfxCertificate -FilePath "$certFolder\DscPrivateKey.pfx" -CertStoreLocation Cert:\LocalMachine\My -Password $mypwd
    } -ArgumentList $certPassword, $certFolder
    $ss | Remove-PSSession
} 
else
{
    Write-Error "The required DSC modules not found"
}

