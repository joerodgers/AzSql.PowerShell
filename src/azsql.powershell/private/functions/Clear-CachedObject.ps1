function Clear-CachedObject
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [string]
        $Name
    )

    Clear-Variable -Name "AzSql.PowerShell.$Name" -Scope "Script" -Force
}