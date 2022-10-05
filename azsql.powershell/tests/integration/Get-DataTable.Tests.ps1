Describe "Testing Get-AzSqlPsDataTable function" -Tag "Integration" {

    BeforeAll {
        Remove-Module -Name "AzSql.PowerShell" -Force -ErrorAction Ignore
        Import-Module -Name "$PSScriptRoot\..\..\AzSql.PowerShell.psd1" -Force

        $contextname = "__AzSql.PowerShell__"

        if( Test-Path -Path "$PSScriptRoot\..\configuration.json" )
        {
            $config = Get-Content "$PSScriptRoot\..\configuration.json" | ConvertFrom-Json

            [Diagnostics.CodeAnalysis.SuppressMessageAttribute("UseDeclaredVarsMoreThanAssignments", "")]
            $database = $config.DatabaseName

            [Diagnostics.CodeAnalysis.SuppressMessageAttribute("UseDeclaredVarsMoreThanAssignments", "")]
            $server = $config.DatabaseServer
        }

        $skiptest = ($env:O365_CLIENTID -eq $null) -and ($database -ne $null) -and ($server -ne $null)

        if( -not $skiptest )
        {
            # clear any existing context
            Get-AzContext | Where-Object -Property "Name" -eq $contextname | Remove-AzAccount

            [Diagnostics.CodeAnalysis.SuppressMessageAttribute("UseDeclaredVarsMoreThanAssignments", "")]
            $clientId = $env:O365_CLIENTID

            [Diagnostics.CodeAnalysis.SuppressMessageAttribute("UseDeclaredVarsMoreThanAssignments", "")]
            $thumbprint = $env:O365_THUMBPRINT

            [Diagnostics.CodeAnalysis.SuppressMessageAttribute("UseDeclaredVarsMoreThanAssignments", "")]
            $secret = $env:O365_CLIENTSECRET

            [Diagnostics.CodeAnalysis.SuppressMessageAttribute("UseDeclaredVarsMoreThanAssignments", "")]
            $tenantId = $env:O365_TENANTID

            Connect-AzSqlPsAccount `
                        -ClientId              $clientId `
                        -CertificateThumbprint $thumbprint `
                        -TenantId              $tenantId

            $guid = (New-Guid).ToString()

            Invoke-AzSqlPsNonQuery `
                        -DatabaseName   $database `
                        -DatabaseServer $server  `
                        -Query          "INSERT INTO dbo.SiteCollection (SiteId, SiteUrl) VALUES (@SiteId, @SiteUrl)" `
                        -Parameters     @{ SiteId = $guid; SiteUrl = "https://contoso.sharepoint.com/sites/$guid" }
        }
    }

    It "should retrieve one or more rows from database table as default return type" -Skip:$skiptest {

        $rows = Get-AzSqlPsDataTable `
                    -DatabaseName   $database `
                    -DatabaseServer $server  `
                    -Query          "SELECT SiteId, SiteUrl FROM dbo.SiteCollection WHERE SiteId = @SiteId AND SiteUrl = @SiteUrl" `
                    -Parameters     @{ SiteId = $guid; SiteUrl = "https://contoso.sharepoint.com/sites/$guid" }

        $rows                    | Should -HaveCount 1
        $rows.GetType().Fullname | Should -Be "System.Data.DataRow"
    }
 
    It "should retrieve one or more rows from database table as DataRow" -Skip:$skiptest {

        $rows = Get-AzSqlPsDataTable `
                    -DatabaseName   $database `
                    -DatabaseServer $server  `
                    -Query          "SELECT SiteId, SiteUrl FROM dbo.SiteCollection WHERE SiteId = @SiteId AND SiteUrl = @SiteUrl" `
                    -Parameters     @{ SiteId = $guid; SiteUrl = "https://contoso.sharepoint.com/sites/$guid" } `
                    -As DataRow
    
        $rows                    | Should -HaveCount 1
        $rows.GetType().Fullname | Should -Be "System.Data.DataRow"
    }

    It "should retrieve one or more rows from database table as DataTable" -Skip:$skiptest {

        $rows = Get-AzSqlPsDataTable `
                    -DatabaseName   $database `
                    -DatabaseServer $server  `
                    -Query          "SELECT SiteId, SiteUrl FROM dbo.SiteCollection WHERE SiteId = @SiteId AND SiteUrl = @SiteUrl" `
                    -Parameters     @{ SiteId = $guid; SiteUrl = "https://contoso.sharepoint.com/sites/$guid" } `
                    -As DataTable
    
        $rows.GetType().Fullname | Should -Be "System.Data.DataTable"
    }

    It "should retrieve one or more rows from database table as PSObject" -Skip:$skiptest {

        $object = Get-AzSqlPsDataTable `
                    -DatabaseName   $database `
                    -DatabaseServer $server  `
                    -Query          "SELECT SiteId, SiteUrl FROM dbo.SiteCollection WHERE SiteId = @SiteId AND SiteUrl = @SiteUrl" `
                    -Parameters     @{ SiteId = $guid; SiteUrl = "https://contoso.sharepoint.com/sites/$guid" } `
                    -As PSObject
    
        $object.GetType().Fullname | Should -Be "System.Management.Automation.PSCustomObject"
        $object.SiteId             | Should -Be $guid
        $object.SiteUrl            | Should -Be "https://contoso.sharepoint.com/sites/$guid"
    }

    It "should retrieve one or more rows from database table as DataSet" -Skip:$skiptest {

        $rows = Get-AzSqlPsDataTable `
                    -DatabaseName   $database `
                    -DatabaseServer $server  `
                    -Query          "SELECT SiteId, SiteUrl FROM dbo.SiteCollection WHERE SiteId = @SiteId AND SiteUrl = @SiteUrl" `
                    -Parameters     @{ SiteId = $guid; SiteUrl = "https://contoso.sharepoint.com/sites/$guid" } `
                    -As DataSet
    
        $rows.GetType().Fullname | Should -Be "System.Data.DataSet"
    }

    It "should retrieve one or more rows from database table as SingleValue" -Skip:$skiptest {

        $siteId = Get-AzSqlPsDataTable `
                    -DatabaseName   $database `
                    -DatabaseServer $server  `
                    -Query          "SELECT SiteId, SiteUrl FROM dbo.SiteCollection WHERE SiteId = @SiteId AND SiteUrl = @SiteUrl" `
                    -Parameters     @{ SiteId = $guid; SiteUrl = "https://contoso.sharepoint.com/sites/$guid" } `
                    -As SingleValue
    
        $siteId | Should -Be $guid
    }

    AfterAll {

        # remove any mock data
        Invoke-AzSqlPsNonQuery `
            -DatabaseName   $database `
            -DatabaseServer $server  `
            -Query          "DELETE FROM dbo.SiteCollection WHERE SiteId=@SiteId AND SiteUrl = @SiteUrl" `
            -Parameters     @{ SiteId = $guid; SiteUrl = "https://contoso.sharepoint.com/sites/$guid" }

        # clear any existing context
        Get-AzContext | Where-Object -Property "Name" -eq $contextname | Remove-AzAccount

    }
}