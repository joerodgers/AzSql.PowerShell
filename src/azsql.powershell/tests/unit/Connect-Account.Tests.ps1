Describe "Testing Connect-AzSqlAccount cmdlet" -Tag "UnitTest" {

    BeforeAll {
        Remove-Module -Name "AzSql.PowerShell" -Force -ErrorAction Ignore
        Import-Module -Name "$PSScriptRoot\..\..\AzSql.PowerShell.psd1" -Force

        [Diagnostics.CodeAnalysis.SuppressMessageAttribute("UseDeclaredVarsMoreThanAssignments", "")]
        $mockTenantId = (New-Guid).ToString()

        [Diagnostics.CodeAnalysis.SuppressMessageAttribute("UseDeclaredVarsMoreThanAssignments", "")]
        $mockClientId = (New-Guid).ToString()

        [Diagnostics.CodeAnalysis.SuppressMessageAttribute("UseDeclaredVarsMoreThanAssignments", "")]
        $mockThumbprint = (New-Guid).ToString()

        [Diagnostics.CodeAnalysis.SuppressMessageAttribute("UseDeclaredVarsMoreThanAssignments", "")]
        $mockSecret = (New-Guid).ToString() | ConvertTo-SecureString -AsPlainText -Force

        [Diagnostics.CodeAnalysis.SuppressMessageAttribute("UseDeclaredVarsMoreThanAssignments", "")]
        $mockCredential = [System.Management.Automation.PSCredential]::new( $mockClientId, $mockSecret )

        [Diagnostics.CodeAnalysis.SuppressMessageAttribute("UseDeclaredVarsMoreThanAssignments", "")]
        $mockContextName = "__AzSql.PowerShell__"
    }

    It "should create a context using secret parameterset" {

        $filter = {
            $Tenant                                     -eq $mockTenantId                                   -and 
            $Credential.UserName                        -eq $mockCredential.UserName                        -and 
            $Credential.GetNetworkCredential().Password -eq $mockCredential.GetNetworkCredential().Password -and            
            $ServicePrincipal                           -eq $true                                           -and 
            $ContextName                                -eq $mockContextName
        }

        # build mocks
        Mock -CommandName "Connect-AzAccount"        -ModuleName "AzSql.PowerShell" -Verifiable -ParameterFilter $filter 
        Mock -CommandName "Assert-ServiceConnection" -ModuleName "AzSql.PowerShell" -Verifiable 

        # execute mock login
        Connect-AzSqlPsAccount -ClientId $mockClientId -ClientSecret $mockSecret -TenantId $mockTenantId

        # verify mocks
        Should -InvokeVerifiable
    }

    It "should create a context using certificate parameterset" {

        $filter = {
            $Tenant                -eq $mockTenantId   -and 
            $ApplicationId         -eq $mockClientId   -and 
            $CertificateThumbprint -eq $mockThumbprint -and 
            $ServicePrincipal      -eq $true           -and 
            $ContextName           -eq $mockContextName
        }

        # build mocks
        Mock -CommandName "Connect-AzAccount"        -ModuleName "AzSql.PowerShell" -Verifiable -ParameterFilter $filter 
        Mock -CommandName "Assert-ServiceConnection" -ModuleName "AzSql.PowerShell" -Verifiable 

        Connect-AzSqlPsAccount -ClientId $mockClientId -CertificateThumbprint $mockThumbprint -TenantId $mockTenantId

        # verify mocks
        Should -InvokeVerifiable
    }

    It "should create a context using msi parameterset" {

        $filter = { $Identity -eq $true }

        # build mocks
        Mock -CommandName "Connect-AzAccount"        -ModuleName "AzSql.PowerShell" -Verifiable -ParameterFilter $filter 
        Mock -CommandName "Assert-ServiceConnection" -ModuleName "AzSql.PowerShell" -Verifiable 

        # execute mock login
        Connect-AzSqlPsAccount -SystemAssignedManagedIdentity

        # verify mocks
        Should -InvokeVerifiable
    }
}