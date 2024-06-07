function Get-CachedObject
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [string]
        $Name
    )

    if( $variable = Get-Variable -Name "AzSql.PowerShell.$Name" -Scope "Script" -ErrorAction Ignore  )
    {
        return $variable.Value
    }
}