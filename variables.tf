
variable "aciUser" {
    type = string
    default = "adminApi"
}

variable "aciPrivateKey" {
    type = string
    default = "adminApi.key"
}

variable "aciCertName" {
    type = string
    default = "adminApi.crt"
}

variable "aciUrl" {
    default = "https://10.138.159.34" 
}

variable "tenantName" {
    type = string
    default = "demo"
}

variable "tenantDesc" {
    type = string
    default = "Tenant created by Terraform"
}

variable "tenantAlias" {
    type = string
    default = "AciTerraform"
}

variable "vrfName1" {
    type = string
    default = "vrf1"  
}

variable "vrfName2" {
    type = string
    default = "vrf2"  
}

variable "bdName1" {
    type = string
    default = "bd1"
}

variable "bdName2" {
    type = string
    default = "bd2"
}

variable "bdName3" {
    type = string
    default = "bd3"
}

variable "bdSvc" {
    type = string
    default = "bd-svc"
}

variable "bdSubnet1" {
    type = string
    default = "192.168.1.254/24"
}

variable "bdSubnet2" {
    type = string
    default = "192.168.2.254/24"
}

variable "bdSubnet3" {
    type = string
    default = "172.16.1.254/24"
}

variable "bdSvcSubnet" {
    type = string
    default = "192.168.251.254/24"
}

variable "apName" {
    type = string
    default = "ap1"
  
}

variable "epgName1" {
    type = string
    default = "epg1"
}


variable "epgName2" {
    type = string
    default = "epg2"
}

variable "epgName3" {
    type = string
    default = "epg3"
}

variable "vmmDomain" {
    type = string
    default = "POD1_ACI_DS"
  
}

variable "provider_profile_dn" {
   default = "uni/vmmp-VMware"
}

variable "ipFilter" {
    type = string
    default = "ip"
}

variable "ipFilterEntry" {
    type = string
    default = "ip"
}

variable "icmpFilter" {
    type = string
    default = "icmp"
}

variable "icmpFilterEntry" {
    type = string
    default = "icmp"
}

variable "httpFilter" {
    type = string
    default = "http"
}

variable "httpFilterEntry" {
    type = string
    default = "http"
}

variable "sshFilter" {
    type = string
    default = "ssh"
}

variable "sshFilterEntry" {
    type = string
    default = "ssh"
}

variable "epg1_epg2_contract" {
    type = string
    default = "epg1_epg2_contract"
}

variable "epg1_epg3_contract" {
    type = string
    default = "epg1_epg3_contract"
}

variable "epg_l3out_contract" {
    type = string
    default = "epg_l3out_contract"
}

variable "ip_subject" {
    type = string
    default = "ip_subject"
}

variable "ip" {
    type = string
    default = "ip"
}

variable "icmp_subject" {
    type = string
    default = "icmp_subject"
}

variable "http_subject" {
    type = string
    default = "http_subject"
}

variable "ssh_subject" {
    type = string
    default = "ssh_subject"
}

variable "encap-vlan-1911" {
   type = string
   default = "vlan-1911"
}

variable "encap-vlan-1912" {
   type = string
   default = "vlan-1912"
}


variable "l3outVpcSideA" {
   type = string
   default = "172.16.7.1/24"
}

variable "l3outVpcSideB" {
   type = string
   default = "172.16.7.2/24"
}


variable "fw01" {
    type = string
    default = "asav01"
}


variable "redirectIp" {
    type = string
    default = "192.168.251.1"
}

variable "redirectMac" {
    type = string
    default = "00:50:56:b6:09:3b"
}

variable "redirectPolName" {
    type = string
    default = "asav01-onearm"
}
