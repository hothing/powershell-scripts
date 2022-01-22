$users = @{
    user2 = @("Users")
    user3 = @("Users")
    user4 = @("Users", "Remote Desktop Users")
}

foreach ($u in $users.Keys)
{
    Write-Object "Creating user '$u'"
    $usr = New-LocalUser -Name $u -AccountNeverExpires -PasswordNeverExpires -UserMayNotChangePassword
    $grps = $users[$u]
    $grps | % { Add-LocalGroupMember -Group $_ -Member $u }
}

