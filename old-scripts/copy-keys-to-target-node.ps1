$ss = New-PSSession -ComputerName ASC1 -Credential (Get-Credential)
Copy-Item -Path $certFolder -Destination $certFolder -ToSession $ss -Recurse
# Enter-PSSession -Session $ss
$ss | Remove-PSSession