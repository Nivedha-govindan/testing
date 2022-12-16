param(
[string] $RG_NAME,
[string] $REGION,
[string] $WORKSPACE_NAME
)


if ((Get-Module -ListAvailable Az.Accounts) -eq $null)
{
    Install-Module -Name Az.Accounts -Force
}

Write-Output "AZ is installed"
