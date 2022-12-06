function Connect-Account
{
    [cmdletbinding()]
    param
    (
        [Parameter(Mandatory=$true,ParameterSetName="identity")]
        [switch]
        $SystemAssignedManagedIdentity,

        [Parameter(Mandatory=$true,ParameterSetName="secret")]
        [Parameter(Mandatory=$true,ParameterSetName="thumbprint")]
        [string]
        $ClientId,

        [Parameter(Mandatory=$true,ParameterSetName="secret")]
        [SecureString]
        $ClientSecret,

        [Parameter(Mandatory=$true,ParameterSetName="thumbprint")]
        [string]
        $CertificateThumbprint,

        [Parameter(Mandatory=$true,ParameterSetName="secret")]
        [Parameter(Mandatory=$true,ParameterSetName="thumbprint")]
        [string]
        $TenantId
    )

    begin
    {
        $contextname = Get-ContextName
    }
    process
    {
        if( $PSCmdlet.ParameterSetName -eq "secret" )
        {
            $credential = [System.Management.Automation.PSCredential]::new( $ClientId, $ClientSecret )

            $null = Connect-AzAccount `
                            -Credential  $credential `
                            -Tenant      $TenantId `
                            -ContextName $contextname `
                            -ServicePrincipal `
                            -Force
        }
        elseif( $PSCmdlet.ParameterSetName -eq "thumbprint" )
        {
            $null = Connect-AzAccount `
                            -ApplicationId         $ClientId `
                            -CertificateThumbprint $CertificateThumbprint `
                            -ContextName           $contextname `
                            -Tenant                $TenantId `
                            -ServicePrincipal `
                            -Force
        }
        else # managed identity
        {
            $null = Connect-AzAccount `
                            -Identity `
                            -Force
        }

        Assert-ServiceConnection -Cmdlet $PSCmdlet
    }
    end
    {
    }
}
