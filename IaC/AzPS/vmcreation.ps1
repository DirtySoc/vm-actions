# This IaC script provisions a VM within Azure
#
[CmdletBinding()]
param(
    [Parameter(Mandatory = $True)]
    [string]
    $servicePrincipal,

    [Parameter(Mandatory = $True)]
    [string]
    $servicePrincipalSecret,

    [Parameter(Mandatory = $True)]
    [string]
    $servicePrincipalTenantId,

    [Parameter(Mandatory = $True)]
    [string]
    $azureSubscriptionName,

    [Parameter(Mandatory = $True)]
    [string]
    $resourceGroupName,

    [Parameter(Mandatory = $True)]
    [string]
    $resourceGroupNameRegion,

    [Parameter(Mandatory = $True)]  
    [string]
    $serverName,

    [Parameter(Mandatory = $True)]  
    [string]
    $adminLogin,

    [Parameter(Mandatory = $True)]  
    [string]
    $adminPassword
)

#region Login
# This logs into Azure with a Service Principal Account
#
Write-Output "Logging in to Azure with a service principal..."

$cred = ConvertTo-SecureString -String $servicePrincipalSecret -AsPlainText -Force
$pscredential = New-Object -TypeName System.Management.Automation.PSCredential($servicePrincipal, $cred)
Connect-AzAccount -ServicePrincipal -Credential $pscredential -Tenant $servicePrincipalTenantId

Write-Output "Done"
Write-Output ""
#endregion

#region Subscription
#This sets the subscription the resources will be created in

Write-Output "Setting default azure subscription..."

$context = Get-AzSubscription -SubscriptionId $azureSubscriptionName
Set-AzContext $context

Write-Output "Done"
Write-Output ""
#endregion

#region Create Resource Group
# This creates the resource group used to house the VM
Write-Output "Creating resource group $resourceGroupName in region $resourceGroupNameRegion..."

New-AzResourceGroup `
    -Location $resourceGroupNameRegion `
    -Name $resourceGroupName

Write-Output "Done creating resource group"
Write-Output ""
#endregion

#region Create VM
# Create a VM in the resource group
Write-Output "Creating VM..."
try {
    $cred = ConvertTo-SecureString -String $servicePrincipalSecret -AsPlainText -Force
    $cred = New-Object System.Management.Automation.PSCredential ($adminLogin, $cred)
    New-AzVM `
        -ResourceGroupName $resourceGroupName `
        -Name $serverName `
        -Image win2019datacenter `
        -Credential $cred
}
catch {
    Write-Output "VM already exists"
}
Write-Output "Done creating VM"
Write-Output ""
#endregion