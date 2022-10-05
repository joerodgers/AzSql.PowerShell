function Connect-Account
{
    [cmdletbinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [string]
        $ClientId,

        [Parameter(Mandatory=$true,ParameterSetName="secret")]
        [SecureString]
        $ClientSecret,

        [Parameter(Mandatory=$true,ParameterSetName="thumbprint")]
        [string]
        $CertificateThumbprint,

        [Parameter(Mandatory=$true)]
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
        else 
        {
            $null = Connect-AzAccount `
                            -ApplicationId         $ClientId `
                            -CertificateThumbprint $CertificateThumbprint `
                            -ContextName           $contextname `
                            -Tenant                $TenantId `
                            -ServicePrincipal `
                            -Force
        }

        Assert-ServiceConnection -Cmdlet $PSCmdlet
    }
    end
    {
    }
}
