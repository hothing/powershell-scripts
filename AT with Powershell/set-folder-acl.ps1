$folderPath = "C:\TestACL"


function Set-AclSimply
{
    Param(
        [Parameter(Mandatory=$true)][string]$FolderPath, 
        [Parameter(Mandatory=$true)][string]$UserName, 
        [Parameter(Mandatory=$true)][string[]]$Permissions, 
        [switch]$Deny
        )

    if (Test-Path -Path $FolderPath)
    {
        $acl = Get-Acl $FolderPath
        $Mode = "Allow"
        if ($Deny) { $Mode = "Deny" }
        $prms = 0
        foreach ($p in $Permissions)
        {
            $r = [System.Security.AccessControl.FileSystemRights]::Parse([System.Security.AccessControl.FileSystemRights], $p)
            $prms = $prms -bor $r
        }
        $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($UserName, $prms, 3, 1, $Mode)
        $acl.SetAccessRule($AccessRule)
        $acl.SetAccessRuleProtection($false, $true) 
        $acl | Set-Acl $FolderPath
    }
}

#Set-AclSimply $folderPath "user2" @("ReadData", "WriteData")
Set-AclSimply $folderPath "user2" "FullControl"
Set-AclSimply $folderPath "user2" "ReadData" -Deny
