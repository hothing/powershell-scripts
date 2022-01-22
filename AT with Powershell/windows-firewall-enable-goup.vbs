'  This VBScript file includes sample code that enables Windows Firewall
'  rule groups using the Microsoft Windows Firewall APIs.


option explicit

Dim CurrentProfiles

' Create the FwPolicy2 object.
Dim fwPolicy2
Set fwPolicy2 = CreateObject("HNetCfg.FwPolicy2")

' Get the Rules object
Dim RulesObject
Set RulesObject = fwPolicy2.Rules

CurrentProfiles = fwPolicy2.CurrentProfileTypes
fwPolicy2.EnableRuleGroup CurrentProfiles, "File and Printer Sharing", TRUE
