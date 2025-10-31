# Powershell 6 and up 

In Powershell 6 and up you can add '-SkipCertificateCheck' to ignore certificate validation.

# Powershell 5 and below

In Powershell 5 and below you must do a little more, to override the normal 'failure' of cert validation (force a valid state / no-error)

```powershell
if (-not("dummy" -as [type])) {
    add-type -TypeDefinition @"
using System;
using System.Net;
using System.Net.Security;
using System.Security.Cryptography.X509Certificates;

public static class Dummy {
    public static bool ReturnTrue(object sender,
        X509Certificate certificate,
        X509Chain chain,
        SslPolicyErrors sslPolicyErrors) { return true; }

    public static RemoteCertificateValidationCallback GetDelegate() {
        return new RemoteCertificateValidationCallback(Dummy.ReturnTrue);
    }
}
"@
}

[System.Net.ServicePointManager]::ServerCertificateValidationCallback = [dummy]::GetDelegate()
```

