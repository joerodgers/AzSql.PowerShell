function Disconnect-Account
{
    [cmdletbinding()]
    param
    (
    )

    begin
    {
    }
    process
    {
        Clear-CachedObject -Name "Connection" -ErrorAction Stop
    }
    end
    {
    }
}
