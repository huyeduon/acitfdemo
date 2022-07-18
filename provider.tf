terraform {
  required_providers {
    aci = {
      source = "CiscoDevNet/aci"
      version = "2.3.0"
    }
  }
}
provider "aci" {
  # cisco-aci user name
  username = var.aciUser
  # private-key
  private_key = var.aciPrivateKey
  cert_name   = var.aciCertName
  # cisco-aci url
  url      = var.aciUrl
  insecure = true
}