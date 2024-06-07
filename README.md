## Setup/Configuration

#### Create a new Azure AD App Principal
<p align="center" width="100%">
    <kbd><img src="https://user-images.githubusercontent.com/28455042/194133491-f30d9921-6b04-4e50-98ba-c56f1e907727.png" width="800"></kbd>
</p>

#### Upload a certificate (or use a secret)
<p align="center" width="100%">
    <kbd><img src="https://user-images.githubusercontent.com/28455042/194133493-cf3956d4-a5ce-4537-bee2-015952636327.png" width="800"></kbd>
</p>

#### Create a secret (or use a certificate)
<p align="center" width="100%">
    <kbd><img src="https://user-images.githubusercontent.com/28455042/194133492-2c8953bb-a6ca-4002-ac2c-a55cbb13fb03.png" width="800"></kbd>
</p>

#### Create Azure AD Security Group & Add App Principal(s)
<p align="center" width="100%">
    <kbd><img src="https://user-images.githubusercontent.com/28455042/194136607-c1fac1ad-c4f0-41af-9587-e7951eec71a5.png" width="800"></kbd>
</p>

#### Create Azure AD Security Group & Add App Principal(s)
<p align="center" width="100%">
    <kbd><img src="https://user-images.githubusercontent.com/28455042/194136607-c1fac1ad-c4f0-41af-9587-e7951eec71a5.png" width="800"></kbd>
</p>

#### Grant Azure AD Security Group Access to the Azure SQL database

```SQL
CREATE USER [azure-sql-admins] FROM EXTERNAL PROVIDER
GO
EXEC sp_addrolemember 'db_owner', [azure-sql-admins]
```
## Example Usage
### Authenticate to Azure as a service principal

```Powershell
Connect-AzSqlPsAccount `
    -ClientId              $env:O365_CLIENTID `
    -CertificateThumbprint $env:O365_THUMBPRINT `
    -TenantId              $env:O365_TENANTID
```

```Powershell

$certificate = Get-AzKeyVaultCertificate -VaultName "ContosoKV01" -Name "TestCert01"

Connect-AzSqlPsAccount `
    -ClientId    $env:O365_CLIENTID `
    -Certificate $certificate `
    -TenantId    $env:O365_TENANTID
```

```Powershell
Connect-AzSqlPsAccount `
            -ClientId     $env:O365_CLIENTID `
            -ClientSecret $env:O365_CLIENTSECRET `
            -TenantId     $env:O365_TENANTID
```

### Execute query to retrive rows

```Powershell
$rows = Get-AzSqlPsDataTable `
    -Query          "SELECT * FROM sales" `
    -As             "PSObject"
```

```Powershell
$rows = Get-AzSqlPsDataTable `
    -Query          "SELECT * FROM sales WHERE CustomerId = @CustomerId" `
    -Parameters     @{ CustomerId = 1234 } `
    -As             "PSObject" `
```

### Execute query to insert new rows

```Powershell
Invoke-AzSqlPsNonQuery `
    -Query          "INSERT INTO dbo.sales (CustomerId, Amount) VALUES (1, 100)"
```

```Powershell
Invoke-AzSqlPsNonQuery `
    -Query          "INSERT INTO sales (CustomerId, Amount) VALUES (@CustomerId, @Amount)" `
    -Parameters     @{ CustomerId = 1234; Amount = 10000 }
```



### Execute scalar query to return query row count

```Powershell
$count = Invoke-AzSqlPsScalarQuery `
    -Query          "SELECT COUNT(sales) FROM dbo.sales WHERE Amount > 100"
```    

```Powershell
$count = Invoke-AzSqlPsScalarQuery `
    -Query          "SELECT COUNT(sales) WHERE Amount > @Amount" `
    -Parameters     @{ Amount = 10000 }
```    

