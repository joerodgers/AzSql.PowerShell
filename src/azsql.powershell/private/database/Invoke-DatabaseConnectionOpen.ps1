function Invoke-DatabaseConnectionOpen
{
    [cmdletbinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [System.Data.SqlClient.SqlConnection]
        $SqlConnection
    )

    $SqlConnection.Open()
}
