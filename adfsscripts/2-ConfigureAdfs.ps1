Install-AdfsFarm -CertificateThumbprint $myCert `
    -FederationServiceName "sts.lab.flamingkeys.com" `
    -GroupServiceAccountIdentifier "LAB\svc_adfs$"