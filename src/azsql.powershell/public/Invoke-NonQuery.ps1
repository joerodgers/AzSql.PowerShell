<#
 .Synopsis
    Executes the provided TSQL statement against the specified database and SQL instance.

 .EXAMPLE
    Invoke-NonQuery -Query "INSERT INTO Users (UserName, Email) VALUES ('johndoe', 'johndoe@contoso.com')"

 .EXAMPLE
    Invoke-NonQuery -Query "INSERT INTO Users (UserName, Email) VALUES (@UserName, @EmailAddress)" -Parameters @{ UserName = "johndoe"; EmailAddress = "johndoe@contoso.com" } 

 #>
 function Invoke-NonQuery
 {
    [CmdletBinding()]
    param
    (
        # TSQL statement
        [Parameter(Mandatory=$true)]
        [string]
        $Query,

        # Command Type
        [Parameter(Mandatory=$false)]
        [System.Data.CommandType]
        $CommandType = [System.Data.CommandType]::Text,

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
                $command.CommandType    = $CommandType
                
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

                Write-Debug -Message "Executing Query: $Query" -Level Debug
                $null = $command.ExecuteNonQuery()
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
 

