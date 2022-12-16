param(
[string] $RG_NAME,
[string] $REGION,
[string] $WORKSPACE_NAME
)


if ((Get-Module -ListAvailable Az.Accounts) -eq $null)
{
    Install-Module -Name Az.Accounts -Force
}

Write-Output "Task: Generating Databricks Token"
$WORKSPACE_ID = (az resource show --resource-type Microsoft.Databricks/workspaces --resource-group $RG_NAME --name $WORKSPACE_NAME --query id --output tsv)
