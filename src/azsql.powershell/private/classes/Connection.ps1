$typeDefinition = @'
namespace AzSqlPowerShell
{
    public abstract class Connection
    {
        public System.Guid ClientId = System.Guid.Empty;

        public string DatabaseName {get; set;} 

        public string DatabaseServer {get; set;}

        public int ConnectTimeout {get; set;}

        public bool Encrypt {get; set;}

        public System.Guid TenantId = System.Guid.Empty;

        protected Connection()
        {
           ConnectTimeout = 15;
           Encrypt        = true;
        }
    }


    public class ServicePrincipalSecretConnection : Connection
    {
        public System.Security.SecureString ClientSecret = new System.Security.SecureString();
    }

    public class ServicePrincipalCertificateConnection : Connection
    {
        public System.Security.Cryptography.X509Certificates.X509Certificate2 Certificate;
    }
}
'@

if (-not ("AzSqlPowerShell.Connection" -As [type] ))
{
    Add-Type -TypeDefinition $typeDefinition
}
