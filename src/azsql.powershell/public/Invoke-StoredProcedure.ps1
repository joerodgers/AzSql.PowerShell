function Invoke-StoredProcedure
{
   [CmdletBinding()]
   param
   (
        # TSQL statement
        [Parameter(Mandatory=$true)]
        [string]
        $StoredProcedure,

        # Hashtable of parameters to the SQL query.  Do not include the '@' character in the key name.
        [Parameter(Mandatory=$false)]
        [HashTable]
        $Parameters = @{},

        # Specifies output type. Valid options for this parameter are 'DataSet', 'DataTable', 'DataRow', 'PSObject', and 'SingleValue'
        [Parameter(Mandatory=$false)]
        [ValidateSet("DataSet", "DataTable", "DataRow", "PSObject", "SingleValue")]
        [string]
        $As = "DataRow",

        # SQL command timeout. Default is 30 seconds
        [Parameter(Mandatory=$false)]
        [int]
        $CommandTimeout = 30
    )

    begin
    {
    }
    process
    {
        try
        {
            if( $connection = New-DatabaseConnection )
            {
                $command = New-Object System.Data.SqlClient.SqlCommand($StoredProcedure, $connection)     
                $command.CommandTimeout = $CommandTimeout
                $command.CommandType    = [System.Data.CommandType]::StoredProcedure

                foreach( $parameter in $Parameters.GetEnumerator() )
                {
                    if( $null -eq $parameter.Value )
                    {
                        Write-Debug -Message "Parameter: $($parameter.Key), Value=DBNULL"
                        $null = $command.Parameters.AddWithValue( "@$($parameter.Key)", [System.DBNull]::Value )
                    }
                    else 
                    {
                        Write-Debug -Message "Parameter: $($parameter.Key), Value='$($parameter.Value)'"
                        $null = $command.Parameters.AddWithValue( "@$($parameter.Key)", $parameter.Value )
                    }
                }

                Write-Debug -Message "Executing stored procedure: '$StoredProcedure'"

                $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

                $dataSet     = New-Object System.Data.DataSet     
                $dataAdapter = New-Object System.Data.SqlClient.SqlDataAdapter( $command )
                $dataAdapter.Fill($dataSet)

                Write-Debug -Message "Executed store procedure '$StoredProcedure' in $($stopwatch.Elapsed.TotalMilliseconds)ms"

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
                        if ($ds.Tables.Count -ne 0)
                        {
                            $dataSet.Tables[0] | Select-Object -ExpandProperty $dataSet.Tables[0].Columns[0].ColumnName
                        }         
                    }
                }
            }
        }
        catch
        {
            Write-Error -Message "Failed to execute stored procedure: $StoredProcedure."
            throw $_.Exception
        }
        finally
        {
            if( $null -ne $command )
            {
                $command.Dispose()
            }

            if( $null -ne $connection )
            {
                $connection.Close()
                $connection.Dispose()
            }
        }
    }
    end
    {
    }
}
 

