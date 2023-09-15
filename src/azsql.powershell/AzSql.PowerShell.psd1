@{
    # Script module or binary module file associated with this manifest.
    RootModule = 'AzSql.PowerShell.psm1'

    # Version number of this module.
    ModuleVersion = '1.2.0'

    # ID used to uniquely identify this module
    GUID = '3d647b5b-7f1a-4116-9748-460ee30778f9'

    # Description of the functionality provided by this module
    Description = 'Module to faciliate manipulating Azure SQL database schema and table data.'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '5.1'

    # import classes
    ScriptsToProcess = @()

    # Assemblies that must be loaded prior to importing this module
    RequiredAssemblies = @()
    
    # Modules that must be imported into the global environment prior to importing this module
    RequiredModules = @(
        @{
            ModuleName    = 'Az.Accounts'
            ModuleVersion = '2.2.7'
        },
        @{
            ModuleName    = 'PSFramework'
            ModuleVersion = '1.6.205'
        }
    )
    
    # Functions to export from this module
    FunctionsToExport = 
        'Connect-Account',
        'Get-DataTable',
        'Invoke-NonQuery',
        'Invoke-ScalarQuery',
        'Invoke-StoredProcedure',
        'Invoke-BulkInsert'

    DefaultCommandPrefix = 'AzSqlPs'
}