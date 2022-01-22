$nugetProvider = "C:\Program Files\PackageManagement\ProviderAssemblies\nuget"

$ss = New-PSSession -ComputerName ASC1 -Credential (Get-Credential)
Copy-Item -Path $nugetProvider -Destination $nugetProvider -ToSession $ss -Recurse
# Do the provider initialization remotly
Invoke-Command -Session $ss -ScriptBlock { Import-PackageProvider -Name NuGet }
# Enter-PSSession -Session $ss
# $env:ProgramData\Microsoft\Windows\PowerShell\PowerShellGet
$ss | Remove-PSSession