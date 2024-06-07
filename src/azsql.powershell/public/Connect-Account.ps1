function Connect-Account
{
    [cmdletbinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [Guid]
        $ClientId,

        [Parameter(Mandatory=$true)]
        [Guid]
        $TenantId,

        [Parameter(Mandatory=$false)]
        [string]
        $DatabaseName,

        [Parameter(Mandatory=$false)]
        [string]
        $DatabaseServer,

        [Parameter(Mandatory=$true,ParameterSetName="secret")]
        [SecureString]
        $ClientSecret,

        [Parameter(Mandatory=$true,ParameterSetName="thumbprint")]
        [string]
        $CertificateThumbprint,

        [Parameter(Mandatory=$true,ParameterSetName="certificate")]
        [System.Security.Cryptography.X509Certificates.X509Certificate2]
        $Certificate
    )

    begin
    {
    }
    process
    {
        if( $PSCmdlet.ParameterSetName -eq "secret" )
        {
            $connection = New-Object AzSqlPowerShell.ServicePrincipalSecretConnection
            $connection.DatabaseName   = $DatabaseName
            $connection.DatabaseServer = $DatabaseServer
            $connection.ClientId       = $ClientId
            $connection.TenantId       = $TenantId
            $connection.ClientSecret   = $ClientSecret
        }
        elseif( $PSCmdlet.ParameterSetName -eq "certificate" )
        {
            $connection = New-Object AzSqlPowerShell.ServicePrincipalCertificateConnection
            $connection.DatabaseName   = $DatabaseName
            $connection.DatabaseServer = $DatabaseServer
            $connection.ClientId       = $ClientId
            $connection.TenantId       = $TenantId
            $connection.Certificate    = $Certificate
        }
        elseif( $PSCmdlet.ParameterSetName -eq "thumbprint" )
        {
            $connection = New-Object AzSqlPowerShell.ServicePrincipalCertificateConnection
            $connection.DatabaseName   = $DatabaseName
            $connection.DatabaseServer = $DatabaseServer
            $connection.ClientId       = $ClientId
            $connection.TenantId       = $TenantId

            if( $cert = Get-ChildItem -Path "Cert:\CurrentUser\My\$CertificateThumbprint" -ErrorAction SilentlyContinue )
            {
                $connection.Certificate = $cert
            }
            elseif( $cert = Get-ChildItem -Path "Cert:\LocalMachine\My\$CertificateThumbprint" -ErrorAction SilentlyContinue)
            {
                $connection.Certificate = $cert
            }
            else
            {
                throw "Certificate not found."
            }
        }
        else
        {
            throw "Unknown parameter set"
        }

        Set-CachedObject -Name "Connection" -Object $connection
    }
    end
    {
    }
}
