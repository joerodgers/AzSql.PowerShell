﻿function Invoke-BulkInsert 
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory=$true)]
        [System.Data.DataTable]
        $DataTable,
   
        [parameter(Mandatory=$true)]
        [string]
        $DestinationTableName,

        [Parameter(Mandatory=$false)]
        [int]
        $ConnectionTimeout = 15,
    
        [Parameter(Mandatory=$false)]
        [int]
        $BatchSize = 100000,

        [Parameter(Mandatory=$false)]
        [int]
        $NotifyAfter = 10000,

        [Parameter(Mandatory=$false)]
        [Hashtable]
        $ColummMappings = @{}
    )
    begin 
    {
        $rowsCopiedEvent = { Write-Verbose "$($args[1].RowsCopied) rows inserted" }
    }
    process
    {
        try
        {
            if( $connection = New-DatabaseConnection )
            {
                # create the bulk insert object
                $bulkCopy = New-Object System.Data.SqlClient.SqlBulkCopy($connection)
                $bulkCopy.DestinationTableName = $DestinationTableName
                $bulkCopy.BatchSize            = $BatchSize
                $bulkCopy.BulkCopyTimeout      = 10000000
                $bulkCopy.NotifyAfter          = $NotifyAfter
                $bulkCopy.Add_SqlRowsCopied( $rowsCopiedEvent )
                
                # build a default mapping using the provided columns if no customer mappings provided
                if( -not $PSBoundParameters.ContainsKey( "ColummMappings" ) )
                {
                    foreach( $column in $DataTable.Columns )
                    {
                        $ColummMappings[$column.ColumnName] = $column.ColumnName
                    }
                }

                # set the column mappings
                foreach( $mapping in $ColummMappings.GetEnumerator() )
                {
                    $bulkCopy.ColumnMappings.Add( $mapping.Key, $mapping.Value )
                }

                # insert the data 
                $bulkCopy.WriteToServer($DataTable)
            }
        }
        finally
        {
            if( $null -ne $bulkCopy )
            {
                $bulkCopy.Close()
                $bulkCopy.Dispose()
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