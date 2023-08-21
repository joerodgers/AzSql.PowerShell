function Get-DataTable
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [string]
        $DatabaseName,

        [Parameter(Mandatory=$true)]
        [string]
        $DatabaseServer,

        # TSQL statement
        [Parameter(Mandatory=$true)]
        [string]
        $Query,

        # Command Timeout
        [Parameter(Mandatory=$false)]
        [int]
        $CommandTimeout=30, # The default is 30 seconds
        
        # Hashtable of parameters to the SQL query.  Do not include the '@' character in the key name.
        [Parameter(Mandatory=$false)]
        [HashTable]
        $Parameters = @{},

        # Specifies output type. Valid options for this parameter are 'DataSet', 'DataTable', 'DataRow', 'PSObject', and 'SingleValue'
        [Parameter(Mandatory=$false)]
        [ValidateSet("DataSet", "DataTable", "DataRow", "PSObject", "SingleValue")]
        [string]
        $As = "DataRow"
    )
    begin
    {
        Assert-ServiceConnection -Cmdlet $PSCmdlet
    }
    process
    {
        try
        {
            $connection = New-DatabaseConnection -DatabaseName $DatabaseName -DatabaseServer $DatabaseServer

            $command = New-Object system.Data.SqlClient.SqlCommand($Query, $connection)     
            $command.CommandTimeout = $CommandTimeout

            $dataSet     = New-Object System.Data.DataSet     
            $dataAdapter = New-Object System.Data.SqlClient.SqlDataAdapter( $command )

            foreach( $parameter in $Parameters.GetEnumerator() )
            {
                if( $null -eq $parameter.Value )
                {
                    $null = $command.Parameters.AddWithValue( "@$($parameter.Key)", [System.DBNull]::Value )
                }
                else 
                {
                    $null = $command.Parameters.AddWithValue( "@$($parameter.Key)", $parameter.Value )
                }
            }

            $null = $dataAdapter.Fill($dataSet)

            switch( $As )
            {
                "DataSet"
                {
                    $dataSet
                }
                "DataTable"
                {
                    $dataSet.Tables
                }
                "DataRow"
                {
                    if ($dataSet.Tables.Count -gt 0)
                    {
                        $dataSet.Tables[0]
                    }                
                }
                "PSObject"
                {
                    if ($dataSet.Tables.Count -ne 0) 
                    {
                        $dataSet.Tables[0] | ConvertTo-PSCustomObject
                    }
                }
                "SingleValue"
                {
                    if ($dataSet.Tables.Count -ne 0)
                    {
                        $dataSet.Tables[0].Rows[0] | Select-Object -ExpandProperty $dataSet.Tables[0].Columns[0].ColumnName
                    }         
                }
            }
        }
        catch
        {
            throw $_.Exception
        }
        finally
        {
            if($dataSet)
            {
                $dataSet.Dispose()
            }

            if($dataAdapter)
            {
                $dataAdapter.Dispose()
            }
        }
    }
    end
    {
    }
}

