param(
[string] $REGION,
[string] $WORKSPACE_ID,
[string] $TOKEN,
[string] $AZ_TOKEN
)

if ((Get-Module -ListAvailable Az.Accounts) -eq $null)
{
    Install-Module -Name Az.Accounts -Force
}

$HEADERS = @{
    "Authorization" = "Bearer $TOKEN"
    "X-Databricks-Azure-SP-Management-Token" = "$AZ_TOKEN"
    "X-Databricks-Azure-Workspace-Resource-Id" = "$WORKSPACE_ID"
}
$BODY = @'
{ "lifetime_seconds": 1200, "comment": "ARM deployment" }
'@
$DB_PAT = ((Invoke-RestMethod -Method POST -Uri "https://$REGION.azuredatabricks.net/api/2.0/token/create" -Headers $HEADERS -Body $BODY).token_value)

Write-Output "Task: Creating cluster"
$HEADERS = @{
    "Authorization" = "Bearer $DB_PAT"
    "Content-Type" = "application/json"
}
$BODY = @"
{"cluster_name": "testdbcluster1", "spark_version": "11.3.x-scala2.12", "autotermination_minutes": 30, "num_workers": "4", "node_type_id": "Standard_DS3_v2", "driver_node_type_id": "Standard_DS3_v2" }
"@
$CLUSTER_ID = ((Invoke-RestMethod -Method POST -Uri "https://$REGION.azuredatabricks.net/api/2.0/clusters/create" -Headers $HEADERS -Body $BODY).cluster_id)
if ( $CLUSTER_ID -ne "null" ) {
    Write-Output "[INFO] CLUSTER_ID: $CLUSTER_ID"
} else {
    Write-Output "[ERROR] cluster was not created"
    exit 1
}

Write-Output "Task: Checking cluster"
$RETRY_LIMIT = 15
$RETRY_TIME = 60
$RETRY_COUNT = 0
for( $RETRY_COUNT = 1; $RETRY_COUNT -le $RETRY_LIMIT; $RETRY_COUNT++ ) {
    Write-Output "[INFO] Attempt $RETRY_COUNT of $RETRY_LIMIT"
    $HEADERS = @{
        "Authorization" = "Bearer $DB_PAT"
    }
    $STATE = ((Invoke-RestMethod -Method GET -Uri "https://$REGION.azuredatabricks.net/api/2.0/clusters/get?cluster_id=$CLUSTER_ID" -Headers $HEADERS).state)
    if ($STATE -eq "RUNNING") {
        Write-Output "[INFO] Cluster is running, pipeline has been completed successfully"
        return
    } else {
        Write-Output "[INFO] Cluster is still not ready, current state: $STATE Next check in $RETRY_TIME seconds.."
        Start-Sleep -Seconds $RETRY_TIME
    }
}
Write-Output "[ERROR] No more attempts left, breaking.."
exit 1
