function Invoke-ScalarQuery
 {
    [CmdletBinding()]
    param
    (
        # TSQL statement
        [Parameter(Mandatory=$true)]
        [string]
        $Query,

        # Hashtable of parameters to the SQL query.  Do not include the '@' character in the key name.
        [Parameter(Mandatory=$false)]
        [HashTable]
        $Parameters = @{},

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
                $command = New-Object System.Data.SqlClient.SqlCommand($Query, $connection)     
                $command.CommandTimeout = $CommandTimeout

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

                Write-Debug -Message "Executing Query: $Query"

                $command.ExecuteScalar()
            }
        }
        catch
        {
            Write-Error -Message "Failed to execute non-query: $Query"
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
 

