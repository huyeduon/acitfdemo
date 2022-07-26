# acitfdemo
1. aci terraform provider authentication.
There are 2 options to authenticate with ACI fabric: using password or using cert.

To use password: Simply add password = "..." to provider script.

provider "aci" {
  username = var.aciUser
  password = "apicPassword"
  url      = var.aciUrl
  insecure = true
}

To use cert:
Create cert file using openssl or equivalent tool:

openssl req -new -newkey rsa:1024 -days 36500 -nodes -x509 -keyout adminApi.key -out adminApi.crt -subj '/CN=admiApi/O=Cisco Systems/C=US'
openssl x509 -text -in adminApi.crt

Create a local username adminApi (for example).
Add X509 certificate for above local user. Content of certicate file is similar to this format:

-----BEGIN CERTIFICATE-----
MIIB5zCCAVACCQCLbp30HRqWgTANBgkqhkiG9w0BAQsFADA3MRAwDgYDVQQDDAdh
ZG1pascasc8gU3lzdGVtczELMAkGA1UEBhMCVVMwgZ8wDQYJKoZI
hvcNAQEBBQADgY0AMIGJAoGBadcascaUUEblnynRPQ1rx0LEqV9V4JRYAW
+JUG6CKBscacdakLGMKkDalGcdWTUhFpGpDvTFFSHPhwYlW8/iIasgQl6Y4DiHal
pRTDAgMBsacascdYJKoZIhvcNAQELBQADgYEAQcDw7ddd9/CaUpz836xmvv8sUz+z
vRj0XfPCOQVpjWsV5Tz79U1V+sbKCCNvlFOUXK0Ne1A0tEcdpEPggKLYX/Tz4C64
dJBf1RKVw1Y+ZGypMHTYI1vqqATTORaVpILEW8/J4AaHL7Yszem+fZHM8elNS36w
626zCmALmV1HMnU=
-----END CERTIFICATE-----


2. Customize your script:
Take a look at variables.tf file, it is self explanatory. 
In this demo, we assume that VMM domain and physical domain and layer 3 domain (external domain) are already created on APIC. The main.tf script use data source for those domains. 

What does the script do:
- Create tenant, vrf, bd, service bd
- Create epg, map epg to VMM domain, physical domain, deploy EPG to vmm and physical domains
- Create filter, contracts 
- Create L3Out OSPF
- Apply contract between epg, epg to external epg
- Create service node (Firewall)
- Create service graph template
- Create service redirect policy 

Main.tf script is self explanatory as well with comments embedded.

3. How to run:

terraform plan\
terraform apply 


References:
https://registry.terraform.io/providers/CiscoDevNet/aci/latest/docs
