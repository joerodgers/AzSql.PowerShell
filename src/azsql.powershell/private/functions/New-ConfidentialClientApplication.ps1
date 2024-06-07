function New-ConfidentialClientApplication
{
    [CmdletBinding()]
    param
    (
    )

    begin
    {
        $connection = Get-CachedObject -Name "Connection"
    }
    process
    {
        if( $null -eq $connection )
        {
            throw "No connection found. Please connect using Connect-AzSqlPsAccount before running commands."
        }

        $confidentialClientApplication = Get-CachedObject -Name "ConfidentialClientApplication"

        if( $null -eq $confidentialClientApplication )
        {
            Write-Verbose "[$(Get-Date)] - Creating ConfidentialClientApplication using $($connection.GetType().FullName)"

            $confidentialClientApplication = [Microsoft.Identity.Client.ConfidentialClientApplicationBuilder]::Create($connection.ClientId). `
                                                                                                               WithTenantId($connection.TenantId). `
                                                                                                               WithLegacyCacheCompatibility($false)

            if( $connection -is [AzSqlPowerShell.ServicePrincipalSecretConnection] )
            {
                Write-Verbose "[$(Get-Date)] - Creating ConfidentialClientApplication using client secret"

                $secret = $connection.ClientSecret | ConvertFrom-SecureString -AsPlainText 

                $confidentialClientApplication = $confidentialClientApplication.WithSecret($secret).Build() 
            }
            elseif( $connection -is [AzSqlPowerShell.ServicePrincipalCertificateConnection] )
            {
                Write-Verbose "[$(Get-Date)] - Creating ConfidentialClientApplication using certificate"

                $confidentialClientApplication = $confidentialClientApplication.WithCertificate($connection.Certificate).Build() 
            }
            else
            {
                throw "Invalid connection type."
            }

            
            Set-CachedObject -Name "ConfidentialClientApplication" -Object $confidentialClientApplication
        }
    
        return $confidentialClientApplication
    }
    end
    {
    }
}