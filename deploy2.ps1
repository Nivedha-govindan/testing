param(
[string] $REGION
)

if ((Get-Module -ListAvailable Az.Accounts) -eq $null)
{
    Install-Module -Name Az.Accounts -Force
}

