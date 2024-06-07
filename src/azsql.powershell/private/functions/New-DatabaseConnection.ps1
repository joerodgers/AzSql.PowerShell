function New-DatabaseConnection
{
    [cmdletbinding()]
    param
    (
    )

    begin
    {
    }
    process
    {
        $connection = Get-CachedObject -Name "Connection"

        $sqlConnectionStringBuilder = New-Object System.Data.SqlClient.SqlConnectionStringBuilder
        $sqlConnectionStringBuilder.PSBase.InitialCatalog           = $connection.DatabaseName
        $sqlConnectionStringBuilder.PSBase.DataSource               = $connection.DatabaseServer
        $sqlConnectionStringBuilder.PSBase.IntegratedSecurity       = $true
        $sqlConnectionStringBuilder.PSBase.ConnectTimeout           = 30
        $sqlConnectionStringBuilder.PSBase.Encrypt                  = $true
        $sqlConnectionStringBuilder.PSBase.TrustServerCertificate   = $true
        $sqlConnectionStringBuilder.PSBase.MultipleActiveResultSets = $false
        $sqlConnectionStringBuilder.PSBase.IntegratedSecurity       = $false
        $sqlConnectionStringBuilder.PSBase.PersistSecurityInfo      = $true # allows the AccessToken property to the viewed after the connection is made

        $sqlConnection = New-Object System.Data.SqlClient.SqlConnection($sqlConnectionStringBuilder.PSBase.ConnectionString)
        $sqlConnection.AccessToken = New-AzureSqlAccessToken
        $sqlConnection.Open()

        if( -not $sqlConnection -or $sqlConnection.State -ne "Open" )
        {
            throw "Failed to open sql connection."
        }
        
        return $sqlConnection
    }
    end
    {
    }
}
