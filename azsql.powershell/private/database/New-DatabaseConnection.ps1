function New-DatabaseConnection
{
    [cmdletbinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [string]
        $DatabaseName,

        [Parameter(Mandatory=$true)]
        [string]
        $DatabaseServer
    )

    begin
    {
        Assert-ServiceConnection -Cmdlet $PSCmdlet

        $contextName = Get-ContextName
        $context = Get-AzContext -Name $contextName
    }
    process
    {
        $token = Get-AccessToken -Context $context

        $sqlConnectionStringBuilder = New-Object System.Data.SqlClient.SqlConnectionStringBuilder
        $sqlConnectionStringBuilder.PSBase.InitialCatalog           = $DatabaseName
        $sqlConnectionStringBuilder.PSBase.DataSource               = $DatabaseServer
        $sqlConnectionStringBuilder.PSBase.IntegratedSecurity       = $true
        $sqlConnectionStringBuilder.PSBase.ConnectTimeout           = 30
        $sqlConnectionStringBuilder.PSBase.Encrypt                  = $true
        $sqlConnectionStringBuilder.PSBase.TrustServerCertificate   = $true
        $sqlConnectionStringBuilder.PSBase.MultipleActiveResultSets = $false
        $sqlConnectionStringBuilder.PSBase.IntegratedSecurity       = $false
        $sqlConnectionStringBuilder.PSBase.PersistSecurityInfo      = $true # allows the AccessToken property to the viewed after the connection is made

        $connection = New-Object System.Data.SqlClient.SqlConnection($sqlConnectionStringBuilder.PSBase.ConnectionString)
        $connection.AccessToken = $token.AccessToken

        Invoke-DatabaseConnectionOpen -SqlConnection $connection

        Assert-DatabaseConnectionOpen -SqlConnection $connection -Cmdlet $PSCmdlet

        return $connection
    }
    end
    {
    }
}
