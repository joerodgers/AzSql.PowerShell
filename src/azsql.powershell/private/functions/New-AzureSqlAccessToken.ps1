function New-AzureSqlAccessToken
{
    [cmdletbinding()]
    param
    (
    )

    begin
    {
        $scopes = New-Object System.Collections.Generic.List[string]
        $scopes.Add("https://database.windows.net/.default")
    }
    process
    {
        $confidentialClientApplication = New-ConfidentialClientApplication

        $result = $confidentialClientApplication.AcquireTokenForClient( $scopes ). `
                                                 ExecuteAsync(). `
                                                 GetAwaiter(). `
                                                 GetResult()

        $result.AccessToken
    }
}

