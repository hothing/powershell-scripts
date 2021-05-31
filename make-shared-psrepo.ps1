$localRepo = "c:\PsRepository"
$userNorm = "Everyone"
$userAdmin = "Administrators"

if (-not (Test-Path $localRepo)) {
    md $localRepo -force -Verbose
    $fldAcl = Get-Acl $localRepo
    $aceEveryone = New-Object System.Security.AccessControl.FileSystemAccessRule ($userNorm, "ReadAndExecute", "Allow")
    $aceAdmins = New-Object System.Security.AccessControl.FileSystemAccessRule ($userAdmin, "FullControl", "Allow")
    #$fldAcl.SetAccessRule($ace)
    $fldAcl.AddAccessRule($aceEveryone)
    $fldAcl.AddAccessRule($aceAdmins)
    $fldAcl | Set-Acl $localRepo
}

New-SmbShare -Name share -Path $localRepo -ReadAccess $userNorm -FullAccess $userAdmin

