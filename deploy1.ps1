param(
[string] $RG_NAME,
[string] $WORKSPACE_NAME
)


Write-Output "Task: Generating Databricks Token"
$WORKSPACE_ID = (az resource show --resource-type Microsoft.Databricks/workspaces --resource-group $RG_NAME --name $WORKSPACE_NAME --query id --output tsv)
$TOKEN = (az account get-access-token --resource '2ff814a6-3304-4ab8-85cb-cd0e6f879c1d' | jq --raw-output '.accessToken')
$AZ_TOKEN = (az account get-access-token --resource https://management.core.windows.net/ | jq --raw-output '.accessToken')
