param(
[string] $RG_NAME,
[string] $REGION,
[string] $WORKSPACE_NAME
)

$az = Install-Module -Name Az -Force

if ((Get-Module -ListAvailable Az.Accounts) -eq $null)
{
    Install-Module -Name Az.Accounts -Force
}

$WORKSPACE_ID = (az resource show --resource-type Microsoft.Databricks/workspaces --resource-group $RG_NAME --name $WORKSPACE_NAME --query id --output tsv)
