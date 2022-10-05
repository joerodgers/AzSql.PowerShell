function Get-AccessToken
{
    [cmdletbinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [Microsoft.Azure.Commands.Profile.Models.Core.PSAzureContext]
        $Context
    )

    begin
    {
        Assert-ServiceConnection -Cmdlet $PSCmdlet
    }
    process
    {
        return [Microsoft.Azure.Commands.Common.Authentication.AzureSession]::Instance.AuthenticationFactory.Authenticate(
            $Context.Account,                # account
            $Context.Environment,            # environment
            $Context.Tenant.Id,              # tenantid
            $null,                           # password
            "Never",                         # promptBehavior
            $null,                           # prompt action
            "https://database.windows.net/"  # reourceId
        )
    }
    end
    {
    }
}
