function Set-CachedObject
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [string]
        $Name,

        [Parameter(Mandatory=$true)]
        [object]
        $Object
    )

    Set-Variable -Name "AzSql.PowerShell.$Name" -Scope "Script" -Value $Object
}