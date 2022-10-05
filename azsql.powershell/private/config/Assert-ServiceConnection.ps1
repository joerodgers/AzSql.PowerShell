function Assert-ServiceConnection
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [System.Management.Automation.Cmdlet]
        $Cmdlet
    )

    begin
    {
        $contextname = Get-ContextName       
    }
    process
    {
        if( -not (Get-AzContext -ListAvailable | Where-Object -Property "Name" -eq $contextname) )
        {
            $exception   = [System.InvalidOperationException]::new("Service connection not connected.  Run Connect-AzureSqlAccount before running database commands.")
            $errorRecord = [System.Management.Automation.ErrorRecord]::new($exception, "NotConnected", 'InvalidOperation', $null)
            $Cmdlet.ThrowTerminatingError($errorRecord)
        }
    }    
}