function Decl-Const ($name, $value) { New-Variable -Name $name -Value $value -Option Constant -Scope Global }
# Profile Type
Decl-Const NET_FW_PROFILE2_DOMAIN 1
Decl-Const NET_FW_PROFILE2_PRIVATE 2
Decl-Const NET_FW_PROFILE2_PUBLIC 4

# Action
Decl-Const NET_FW_ACTION_BLOCK 0
Decl-Const NET_FW_ACTION_ALLOW 1

#
Decl-Const NET_FW_MODIFY_STATE_OK 0
Decl-Const NET_FW_MODIFY_STATE_GP_OVERRIDE 1
Decl-Const NET_FW_MODIFY_STATE_NO_EXCEPTIONS 2


$fwPolicy2 = New-Object -ComObject "HNetCfg.FwPolicy2"

$cpt = $fwPolicy2.CurrentProfileTypes


function CHECK_ON_PROFILE ($fw, $PROFILE_ID, $PROFILE_NAME)
{
    function get-state ($state) { if ($state) {"ON"} else {"OFF"} }

    $cpt = $fw.CurrentProfileTypes

    if (($cpt -band $PROFILE_ID) -ne 0)
    {
        $state = get-state $fw.FirewallEnabled($PROFILE_ID)
        Write-Output "Firewall is $state on $PROFILE_NAME profile."
    }
    else
    {
        Write-Warning "The profile $PROFILE_NAME is not active {$cpt}"
    }
}

CHECK_ON_PROFILE $fwPolicy2 $NET_FW_PROFILE2_PRIVATE "PRIVATE"
CHECK_ON_PROFILE $fwPolicy2 $NET_FW_PROFILE2_DOMAIN "DOMAIN"
CHECK_ON_PROFILE $fwPolicy2 $NET_FW_PROFILE2_PUBLIC "PUBLIC"