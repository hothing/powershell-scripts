function Decl-Const ($name, $value) { New-Variable -Name $name -Value $value -Option Constant -Scope Global }

# Profile Type
Decl-Const NET_FW_PROFILE2_DOMAIN 1
Decl-Const NET_FW_PROFILE2_PRIVATE 2
Decl-Const NET_FW_PROFILE2_PUBLIC 4
# Modification modes
Decl-Const NET_FW_MODIFY_STATE_OK 0
Decl-Const NET_FW_MODIFY_STATE_GP_OVERRIDE 1
Decl-Const NET_FW_MODIFY_STATE_NO_EXCEPTIONS 2

$fwPolicy2 = New-Object -ComObject "HNetCfg.FwPolicy2"

$FwRulesGroup = "File and Printer Sharing"
$bIsEnabled = $fwPolicy2.IsRuleGroupEnabled($NET_FW_PROFILE2_PRIVATE, $FwRulesGroup)

if ($bIsEnabled)
{
    Write-Output "The rules group '$FwRulesGroup' is enabled."

    $PolicyModifyState = $fwPolicy2.LocalPolicyModifyState

    switch ($PolicyModifyState)
    {
        $NET_FW_MODIFY_STATE_OK { Write-Output "Changing or adding a firewall rule (or group) will take effect on at least one of the current profiles." }
        $NET_FW_MODIFY_STATE_GP_OVERRIDE { Write-Output "Changing or adding a firewall rule (or group) to the current profiles will not take effect because group policy overrides it on at least one of the current profiles." }
        $NET_FW_MODIFY_STATE_NO_EXCEPTIONS { Write-Output "Changing or adding an inbound firewall rule (or group) to the current profiles will not take effect because inbound rules are not allowed on at least one of the current profiles." }
        default { Write-Output "Invalid Modify State returned by LocalPolicyModifyState." }
    }
}
