function ConvertTo-DataTable
{
    [cmdletbinding()]
    param
    (
        # input object
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,Position=0)]
        [PSObject]
        $InputObject,

        # use a prebuilt datatable, which is required if you want to provide additional columns or specific column types.
        [Parameter(Mandatory=$false)]
        [System.Data.DataTable]
        $DataTable = [System.Data.DataTable]::new()
    )

    begin
    {
        $columnNames = @()
    }
    process
    {
        if( $columnNames.Count -eq  0 )
        {
            if( $InputObject -is [System.Management.Automation.PSCustomObject] )
            {
                $columnNames = ,$InputObject | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name
            }
            elseif( $InputObject -is [Object[]] )
            {
                $columnNames = ,$InputObject[0] | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name
            }
        }

        if( $DataTable.Columns.Count -eq 0 )
        {
            $columnNames | ForEach-Object { $null = $DataTable.Columns.Add( $_ ) }
        }

        foreach( $o in $InputObject )
        {
            $dataRow = $DataTable.NewRow()

            foreach( $columnName in $columnNames )
            {
                if( [string]::IsNullOrEmpty( $o.$columnName ) )
                {
                    $null = $dataRow[ $columnName ] = $null
                }
                else
                {
                    $null = $dataRow[ $columnName ] = $o.$columnName
                }
            }
            
            $null = $DataTable.Rows.Add($dataRow)
        }
    }
    end
    {
        return ,$DataTable
    }
}
