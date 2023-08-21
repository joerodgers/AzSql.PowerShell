Describe "Testing Connect-AzSqlPsAccount function" -Tag "Integration" {

    BeforeAll {

        Remove-Module -Name "AzSql.PowerShell" -Force -ErrorAction Ignore
        Import-Module -Name "$PSScriptRoot\..\..\AzSql.PowerShell.psd1" -Force

        $contextname = "__AzSql.PowerShell__"

        $skiptest = ($env:O365_CLIENTID -eq $null)

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
        }
    }

    It "should create a context using secret parameterset" -Skip:$skiptest {

        $secure = $secret | ConvertTo-SecureString -AsPlainText -Force

        Connect-AzSqlPsAccount -ClientId $clientId -ClientSecret $secure -TenantId $tenantId

        $context = Get-AzContext -Name $contextname
        $context.Name       | Should -Be $contextname
        $context.Tenant.Id  | Should -Be $tenantId
        $context.Account.Id | Should -Be $clientId
    }

    It "should create a context using certificate parameterset" -Skip:$skiptest {

        Connect-AzSqlPsAccount -ClientId $clientId -CertificateThumbprint $thumbprint -TenantId $tenantId

        $context = Get-AzContext -Name $contextname
        $context.Name                           | Should -Be $contextname
        $context.Tenant.Id                      | Should -Be $tenantId
        $context.Account.Id                     | Should -Be $clientId
        $context.Account.CertificateThumbprint  | Should -Be $thumbprint
    }

    AfterAll {

        Get-AzContext | Where-Object -Property "Name" -eq $contextname | Remove-AzAccount
    }
}