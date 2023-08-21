Describe "Testing Invoke-AzSqlPsScalarQuery function" -Tag "Integration" {

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

            # create a new row
            Invoke-AzSqlPsNonQuery `
                        -DatabaseName   $database `
                        -DatabaseServer $server  `
                        -Query          "INSERT INTO dbo.SiteCollection (SiteId, SiteUrl) VALUES (@SiteId, @SiteUrl)" `
                        -Parameters     @{ SiteId = $guid; SiteUrl = "https://contoso.sharepoint.com/sites/$guid" }
    
        }
    }

    It "should return a row count of 1" -Skip:$skiptest {

        $count = Invoke-AzSqlPsScalarQuery `
                    -DatabaseName   $database `
                    -DatabaseServer $server  `
                    -Query          "SELECT COUNT(SiteId) FROM dbo.SiteCollection WHERE SiteId = @SiteId AND SiteUrl = @SiteUrl" `
                    -Parameters     @{ SiteId = $guid; SiteUrl = "https://contoso.sharepoint.com/sites/$guid" } `
    
        $count | Should -Be 1
    }

    It "should return a row count of 0" -Skip:$skiptest {

        $mockguid = (New-Guid).ToString()

        $count = Invoke-AzSqlPsScalarQuery `
                    -DatabaseName   $database `
                    -DatabaseServer $server  `
                    -Query          "SELECT COUNT(SiteId) FROM dbo.SiteCollection WHERE SiteId = @SiteId AND SiteUrl = @SiteUrl" `
                    -Parameters     @{ SiteId = $mockguid; SiteUrl = "https://contoso.sharepoint.com/sites/$mockguid" } `
    
        $count | Should -Be 0
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