Describe "Testing New-DatabaseConnection function" -Tag "UnitTest" {

    BeforeAll {
        Remove-Module -Name "AzSql.PowerShell" -Force -ErrorAction Ignore
        Import-Module -Name "$PSScriptRoot\..\..\AzSql.PowerShell.psd1" -Force
    }

    InModuleScope -ModuleName "AzSql.PowerShell" {

        It "should create a database connection object" {

            function Get-AzContext { param( $Name ) }
            function Get-AccessToken { param( $Context ) }

            $databasename   = (New-Guid).ToString()
            $databaseserver = (New-Guid).ToString()
            $accesstoken    = (New-Guid).ToString()

            # build mocks
            Mock -CommandName "Get-AccessToken"               -ModuleName "AzSql.PowerShell" -Verifiable -MockWith { [PSCustomObject] @{ AccessToken = $accesstoken } }
            Mock -CommandName "Get-AzContext"                 -ModuleName "AzSql.PowerShell" -Verifiable
            Mock -CommandName "Assert-ServiceConnection"      -ModuleName "AzSql.PowerShell" -Verifiable 
            Mock -CommandName "Invoke-DatabaseConnectionOpen" -ModuleName "AzSql.PowerShell" -Verifiable
            Mock -CommandName "Assert-DatabaseConnectionOpen" -ModuleName "AzSql.PowerShell" -Verifiable
            
            # execute mock login
            $connection = New-DatabaseConnection -DatabaseName $databasename -DatabaseServer $databaseserver
            $connection.AccessToken | Should -Be $accesstoken
            $connection.Database    | Should -Be $databasename
            $connection.DataSource  | Should -Be $databaseserver

            # verify mocks
            Should -InvokeVerifiable
        }
    }
}