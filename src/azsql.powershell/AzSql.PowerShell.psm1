#### private functions 

foreach ($function in (Get-ChildItem "$PSScriptRoot\Private" -Filter "*.ps1" -Recurse -ErrorAction Ignore | Sort-Object -Property FullName ))
{
    Write-Verbose "Importing private file: '$($function.FullName)'"

    . $function.FullName
}


#### public functions 

foreach ($function in (Get-ChildItem "$PSScriptRoot\Public" -Filter "*.ps1" -Recurse -ErrorAction Ignore | Sort-Object -Property FullName))
{
    Write-Verbose "Importing public file: '$($function.FullName)'"

    . $function.FullName
}

