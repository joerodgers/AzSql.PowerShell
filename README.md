## Example Usage

### Authenticate to Azure as a service principal

```Powershell

Connect-AzSqlPsAccount `
            -ClientId              $env:O365_CLIENTID `
            -CertificateThumbprint $env:O365_THUMBPRINT `
            -TenantId              $env:O365_TENANTID
```

### Execute query to retrive rows

```Powershell
$rows = Get-AzSqlPsDataTable `
    -DatabaseName   "contoso-sales" `
    -DatabaseServer "contososales.database.windows.net" `
    -Query          "SELECT * FROM sales" `
    -As             "PSObject"
```

```Powershell
$rows = Get-AzSqlPsDataTable `
    -DatabaseName   "contoso-sales" `
    -DatabaseServer "contososales.database.windows.net" `
    -Query          "SELECT * FROM sales WHERE CustomerId = @CustomerId" `
    -Parameters     @{ CustomerId = 1234 } `
    -As             "PSObject" `
```

### Execute query to insert new rows

```Powershell
Invoke-AzSqlPsNonQuery `
    -DatabaseName   "contoso-sales" `
    -DatabaseServer "contososales.database.windows.net" `
    -Query          "INSERT INTO dbo.sales (CustomerId, Amount) VALUES (1, 100)"
```

```Powershell
Invoke-AzSqlPsNonQuery `
    -DatabaseName   "contoso-sales" `
    -DatabaseServer "contososales.database.windows.net" `
    -Query          "INSERT INTO sales (CustomerId, Amount) VALUES (@CustomerId, @Amount)" `
    -Parameters     @{ CustomerId = 1234; Amount = 10000 }
```



### Execute scalar query to return query row count

```Powershell
$count = Invoke-AzSqlPsScalarQuery `
    -DatabaseName   "contoso-sales" `
    -DatabaseServer "contososales.database.windows.net" `
    -Query          "SELECT COUNT(sales) FROM dbo.sales WHERE Amount > 100"
```    

```Powershell
$count = Invoke-AzSqlPsScalarQuery `
    -DatabaseName   "contoso-sales" `
    -DatabaseServer "contososales.database.windows.net" `
    -Query          "SELECT COUNT(sales) WHERE Amount > @Amount" `
    -Parameters     @{ Amount = 10000 }
```    

