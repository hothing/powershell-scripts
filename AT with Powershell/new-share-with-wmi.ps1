# Only for "Run as administrator" mode
([wmiclass]'Win32_Share').Create("C:\TestACL", "Test", 3)

# Variant 2 : it should work, but does not
#$ppx = ([wmiclass]'Win32_Share').GetMethodParameters("Create")
#$ppx.Name = "Test"
#$ppx.Path = "C:\TestACL"
#$ppx.Type = 0
#$res = Invoke-WmiMethod -Class Win32_Share -Name Create -ArgumentList $ppx, $null

# Variant 3: The code below seems to work (only in 'RiA' mode)
$res = Invoke-CimMethod -ClassName Win32_Share -MethodName Create -Arguments @{Name = "games"; Path = "C:\games"; Type = [uint32]0}



