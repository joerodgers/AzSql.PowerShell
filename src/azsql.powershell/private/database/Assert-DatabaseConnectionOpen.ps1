function Assert-DatabaseConnectionOpen
{
    [cmdletbinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [System.Data.SqlClient.SqlConnection]
        $SqlConnection,
        
        [Parameter(Mandatory=$true)]
        [System.Management.Automation.Cmdlet]
        $Cmdlet        
    )

    begin
    {
    }
    process
    {
        if( $SqlConnection.State -ne "Open" )
        {
            $exception   = [System.InvalidOperationException]::new("Database connection not connected.")
            $errorRecord = [System.Management.Automation.ErrorRecord]::new($exception, "NotConnected", 'InvalidOperation', $null)
            $Cmdlet.ThrowTerminatingError($errorRecord)
        }
    }    
}
