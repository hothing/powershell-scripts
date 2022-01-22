$folderPath = "C:\Share"

if (Test-Path -Path $folderPath)
{
    $acl = Get-Acl $folderPath
    $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("user1", "FullControl", 3, 2, "Allow")
    $acl.SetAccessRule($AccessRule)
    $acl.SetAccessRuleProtection($false, $false) 
    $acl | Set-Acl $folderPath
}


