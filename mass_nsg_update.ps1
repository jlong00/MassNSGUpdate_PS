#Declare VNET name and VNET resource group
$vnet = "CanadaEastVN1"
$vnet_rg = "Network_Resources"
$nsg_rg = "nsg"

#Extrapolate subnets from target VNET
$subnets = Get-AzureRmVirtualNetwork -name $vnet -ResourceGroupName $vnet_rg | Get-AzureRmVirtualNetworkSubnetConfig

#Find NSGs attached to each subnet
$subnetrules = $subnets.NetworkSecurityGroup.id 
$nsgs = $subnetrules | select-string -pattern '(?<=/networkSecurityGroups/).*' -AllMatches | foreach {$_.Matches} | ForEach-Object {$_.Value}

#Update all NSGs with below rule
foreach ($nsg in $nsgs)
{
Get-AzureRmNetworkSecurityGroup -Name $nsg -ResourceGroupName $nsg_rg | Add-AzureRmNetworkSecurityRuleConfig `
-Name test-rule123 `
-Description "Testing a new rule add" `
-Access Allow `
-Protocol Tcp `
-Direction Inbound `
-Priority 123 `
-SourceAddressPrefix * `
-SourcePortRange * `
-DestinationAddressPrefix * `
-DestinationPortRange 1443 `
`
| Set-AzureRmNetworkSecurityGroup
}