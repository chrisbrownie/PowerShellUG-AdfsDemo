$adfsFqdn = "sts.lab.flamingkeys.com"

$myCert = Get-Certificate -Template WebServer -CertStoreLocation Cert:\LocalMachine\My `
    -DnsName "$adfsFqdn" -SubjectName "CN=$adfsFqdn" 

Add-KdsRootKey -EffectiveTime (Get-Date).AddHours(-10)

Install-AdfsFarm -CertificateThumbprint $myCert.Certificate.Thumbprint `
    -FederationServiceName "$adfsFqdn" `
    -GroupServiceAccountIdentifier "LAB\svc_adfs$"
