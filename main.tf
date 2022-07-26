resource "aci_tenant" "tfTenant" {
    description = var.tenantDesc
    name        = var.tenantName
}

# Create security policy (contracts and related objects)
# create ip filter
resource "aci_filter" "ipFilter" {
    tenant_dn   = aci_tenant.tfTenant.id
    name        = var.ipFilter
}

# # create icmp filter entry
resource "aci_filter_entry" "ipFilterEntry" {
    filter_dn     = aci_filter.ipFilter.id
    name          = var.ipFilterEntry
    ether_t       = "ip"
    prot          = "unspecified"
}

# create icmp filter
resource "aci_filter" "icmpFilter" {
    tenant_dn   = aci_tenant.tfTenant.id
    name        = var.icmpFilter
}

# create icmp filter entry
resource "aci_filter_entry" "icmpFilterEntry" {
    filter_dn     = aci_filter.icmpFilter.id
    name          = var.icmpFilterEntry
    apply_to_frag = "no"
    arp_opc       = "unspecified"
    d_from_port   = "unspecified"
    d_to_port     = "unspecified"
    ether_t       = "ip"
    icmpv4_t      = "unspecified"
    icmpv6_t      = "unspecified"
    prot          = "icmp"
    s_from_port   = "unspecified"
    s_to_port     = "unspecified"
}

# create http filter
resource "aci_filter" "httpFilter" {
    tenant_dn   = aci_tenant.tfTenant.id
    name        = var.httpFilter
}

# create http filter entry
resource "aci_filter_entry" "httpFilterEntry" {
    filter_dn     = aci_filter.httpFilter.id
    name          = var.httpFilterEntry
    apply_to_frag = "no"
    arp_opc       = "unspecified"
    d_from_port   = "80"
    d_to_port     = "80"
    ether_t       = "ip"
    icmpv4_t      = "unspecified"
    icmpv6_t      = "unspecified"
    prot          = "tcp"
    s_from_port   = "unspecified"
    s_to_port     = "unspecified"
}

# create ssh filter
resource "aci_filter" "sshFilter" {
    tenant_dn   = aci_tenant.tfTenant.id
    name        = var.sshFilter
}

# create ssh filter entry
resource "aci_filter_entry" "sshFilterEntry" {
    filter_dn     = aci_filter.sshFilter.id
    name          = var.sshFilterEntry
    apply_to_frag = "no"
    arp_opc       = "unspecified"
    d_from_port   = "22"
    d_to_port     = "22"
    ether_t       = "ip"
    icmpv4_t      = "unspecified"
    icmpv6_t      = "unspecified"
    prot          = "tcp"
    s_from_port   = "unspecified"
    s_to_port     = "unspecified"
}

# create epg1-epg2 contract
resource "aci_contract" "epg1_epg2_contract" {
    tenant_dn   = aci_tenant.tfTenant.id
    name        = var.epg1_epg2_contract
}

# create epg1-epg3 contract
resource "aci_contract" "epg1_epg3_contract" {
    tenant_dn   = aci_tenant.tfTenant.id
    name        = var.epg1_epg3_contract
    scope       = "tenant"
}

# create l3out epg contract
resource "aci_contract" "epg_l3out_contract" {
    tenant_dn   = aci_tenant.tfTenant.id
    name        = var.epg_l3out_contract
}

# create ip subject
resource "aci_contract_subject" "ip" {
    contract_dn   = aci_contract.epg1_epg3_contract.id
    name          = var.ip
    relation_vz_rs_subj_filt_att = [ aci_filter.ipFilter.id ]
}

# create ip subject
resource "aci_contract_subject" "ip_subject" {
    contract_dn   = aci_contract.epg_l3out_contract.id
    name          = var.ip_subject
    relation_vz_rs_subj_filt_att = [ aci_filter.ipFilter.id ]
}

# create icmp subject
resource "aci_contract_subject" "icmp_subject" {
    contract_dn   = aci_contract.epg1_epg2_contract.id
    name          = var.icmp_subject
    relation_vz_rs_subj_filt_att = [ aci_filter.icmpFilter.id ]
}

# create http subject
resource "aci_contract_subject" "http_subject" {
    contract_dn   = aci_contract.epg1_epg2_contract.id
    name          = var.http_subject
    relation_vz_rs_subj_filt_att = [ aci_filter.httpFilter.id ]
}

# create ssh subject
resource "aci_contract_subject" "ssh_subject" {
    contract_dn   = aci_contract.epg1_epg2_contract.id
    name          = var.ssh_subject
    relation_vz_rs_subj_filt_att = [ aci_filter.sshFilter.id ]
}

# Create networking construct

# create vrf1
resource "aci_vrf" "vrf1" {
    tenant_dn              = aci_tenant.tfTenant.id
    name                   = var.vrfName1
}

# create vrf1
resource "aci_vrf" "vrf2" {
    tenant_dn              = aci_tenant.tfTenant.id
    name                   = var.vrfName2
}

# create bd1
resource "aci_bridge_domain" "bd1" {
    tenant_dn = aci_tenant.tfTenant.id
    relation_fv_rs_ctx = aci_vrf.vrf1.id
    name = var.bdName1
    relation_fv_rs_bd_to_out = [ aci_l3_outside.tfdemo.id ]
}

# create bd2
resource "aci_bridge_domain" "bd2" {
    tenant_dn = aci_tenant.tfTenant.id
    relation_fv_rs_ctx = aci_vrf.vrf1.id
    name = var.bdName2
  
}

# create bd3
resource "aci_bridge_domain" "bd3" {
    tenant_dn = aci_tenant.tfTenant.id
    relation_fv_rs_ctx = aci_vrf.vrf2.id
    name = var.bdName3
  
}

# create subnet1 bd1
resource "aci_subnet" "subnet1" {
    parent_dn = aci_bridge_domain.bd1.id
    ip = var.bdSubnet1
    scope = [ "public","shared" ]
}

# create subnet2 bd2
resource "aci_subnet" "subnet2" {
    parent_dn = aci_bridge_domain.bd2.id
    ip = var.bdSubnet2
    scope = [ "public","shared" ]
}

# create subnet3 bd3
resource "aci_subnet" "subnet3" {
    parent_dn = aci_bridge_domain.bd3.id
    ip = var.bdSubnet3
    scope = [ "public","shared" ]
}

# Create App Logical Construct (AP, EPG...)
# create app profile ap1
resource "aci_application_profile" "ap1" {
    tenant_dn = aci_tenant.tfTenant.id
    name = var.apName
}

# create epg1, map to bd1
resource "aci_application_epg" "epg1" {
    application_profile_dn = aci_application_profile.ap1.id
    name                   = var.epgName1
    relation_fv_rs_bd      = aci_bridge_domain.bd1.id
    relation_fv_rs_cons = [ aci_contract.epg1_epg2_contract.id ,aci_contract.epg1_epg3_contract.id , aci_contract.epg_l3out_contract.id ] 
    relation_fv_rs_prov = [ aci_contract.epg_l3out_contract.id ]
}

# create epg2, map to bd2
resource "aci_application_epg" "epg2" {
    application_profile_dn = aci_application_profile.ap1.id
    name                   = var.epgName2
    relation_fv_rs_bd      = aci_bridge_domain.bd2.id
    relation_fv_rs_prov = [ aci_contract.epg1_epg2_contract.id ]
}

# create epg3, map to bd3
resource "aci_application_epg" "epg3" {
    application_profile_dn = aci_application_profile.ap1.id
    name                   = var.epgName3
    relation_fv_rs_bd      = aci_bridge_domain.bd3.id
    relation_fv_rs_prov = [ aci_contract.epg1_epg3_contract.id ]
}

# Retrieve existing VMM and PhysDomain

data "aci_vmm_domain" "ACI" {
    provider_profile_dn = var.provider_profile_dn
    name                = var.vmmDomain
}

data "aci_physical_domain" "insbu_phys" {
  name  = "insbu_phys"
}

# associate epg1 to VMM domain
resource "aci_epg_to_domain" "epg1Vmm" {
    application_epg_dn    = aci_application_epg.epg1.id
    tdn                   = data.aci_vmm_domain.ACI.id
    vmm_allow_promiscuous = "reject"
    vmm_forged_transmits  = "reject"
    vmm_mac_changes       = "reject"
    instr_imedcy          = "immediate"
    res_imedcy            = "pre-provision"
}

# associate epg2 to VMM domain
resource "aci_epg_to_domain" "epg2Vmm" {
    application_epg_dn    = aci_application_epg.epg2.id
    tdn                   = data.aci_vmm_domain.ACI.id
    vmm_allow_promiscuous = "reject"
    vmm_forged_transmits  = "reject"
    vmm_mac_changes       = "reject"
    instr_imedcy          = "immediate"
    res_imedcy            = "pre-provision"
}

# associate epg3 to VMM domain
resource "aci_epg_to_domain" "epg3Vmm" {
    application_epg_dn    = aci_application_epg.epg3.id
    tdn                   = data.aci_vmm_domain.ACI.id
    vmm_allow_promiscuous = "reject"
    vmm_forged_transmits  = "reject"
    vmm_mac_changes       = "reject"
    instr_imedcy          = "immediate"
    res_imedcy            = "pre-provision"
}


# epg1 to physical domain 
resource "aci_epg_to_domain" "epg1" {
  application_epg_dn    = aci_application_epg.epg1.id
  tdn                   = data.aci_physical_domain.insbu_phys.id
}


# epg static path binding
resource "aci_epg_to_static_path" "epg1-1" {
  application_epg_dn  = aci_application_epg.epg1.id
  tdn  = "topology/pod-1/paths-101/pathep-[eth1/18]"
  encap  = var.encap-vlan
  instr_imedcy = "lazy"
  mode  = "regular"
}

resource "aci_epg_to_static_path" "epg1-2" {
  application_epg_dn  = aci_application_epg.epg1.id
  tdn  = "topology/pod-1/paths-102/pathep-[eth1/18]"
  encap  = var.encap-vlan
  instr_imedcy = "lazy"
  mode  = "regular"
}


# Create L3Out and related objects
 
data "aci_l3_domain_profile" "l3out" {
  name  = "l3out"
}

# create l3out object
resource "aci_l3_outside" "tfdemo" {
    tenant_dn      = aci_tenant.tfTenant.id
    description    = "from terraform"
    name           = "tfdemo"
    annotation     = "tag_l3out"
    enforce_rtctrl = ["export"]
    target_dscp    = "unspecified"
    relation_l3ext_rs_ectx = aci_vrf.vrf1.id
    relation_l3ext_rs_l3_dom_att = data.aci_l3_domain_profile.l3out.id
}

# enable ospf on l3out
resource "aci_l3out_ospf_external_policy" "tfdemo" {
    l3_outside_dn  = aci_l3_outside.tfdemo.id
    description    = "from terraform"
    area_cost      = "1"
    area_ctrl      = ["redistribute", "summary"]
    area_id        = "0.0.0.0"
    area_type      = "regular"
    multipod_internal = "no"
}


 resource "aci_logical_node_profile" "tfdemo_nodeProfile" {
    l3_outside_dn = aci_l3_outside.tfdemo.id
    description   = "ospf logical node profile"
    name          = "tfdemo_nodeProfile"
}


resource "aci_logical_node_to_fabric_node" "node101" {
    logical_node_profile_dn  = aci_logical_node_profile.tfdemo_nodeProfile.id
    tdn               = "topology/pod-1/node-101"
    config_issues     = "none"
    rtr_id            = "7.7.7.1"
    rtr_id_loop_back  = "no"
}

resource "aci_logical_node_to_fabric_node" "node102" {
    logical_node_profile_dn  = aci_logical_node_profile.tfdemo_nodeProfile.id
    tdn               = "topology/pod-1/node-102"
    config_issues     = "none"
    rtr_id            = "7.7.7.2"
    rtr_id_loop_back  = "no"
}


resource "aci_logical_interface_profile" "tfdemo_interface_profile" {
    logical_node_profile_dn = aci_logical_node_profile.tfdemo_nodeProfile.id
    description             = "tfdemo logical interface profile"
    name                    = "tfdemo_int_prof"    
    prio                    = "unspecified"

}

resource "aci_ospf_interface_policy" "tfdemo" {
    tenant_dn    = aci_tenant.tfTenant.id
    name         = "tfdemoBroadcast"
    description  = "from terraform"
    cost         = "unspecified"
    ctrl         = ["advert-subnet", "mtu-ignore"]
    dead_intvl   = "40"
    hello_intvl  = "10"
    nw_t         = "bcast"
}

resource "aci_l3out_ospf_interface_profile" "tfdemo" {
  logical_interface_profile_dn = aci_logical_interface_profile.tfdemo_interface_profile.id
  auth_key_id                  = "1"
  auth_type                    = "none"
  auth_key                     = "key"
  relation_ospf_rs_if_pol      = aci_ospf_interface_policy.tfdemo.id
}

resource "aci_l3out_path_attachment" "tfdemo" {
  logical_interface_profile_dn  = aci_logical_interface_profile.tfdemo_interface_profile.id
  target_dn  = "topology/pod-1/protpaths-101-102/pathep-[3750_VPC]"
  if_inst_t = "ext-svi"
  description = "from terraform"
  encap  = "vlan-700"
  encap_scope = "local"
}

resource "aci_l3out_vpc_member" "tfdemoa" {
  leaf_port_dn  = aci_l3out_path_attachment.tfdemo.id
  side  = "A"
  addr  = var.l3outVpcSideA
}

resource "aci_l3out_vpc_member" "tfdemob" {
  leaf_port_dn  = aci_l3out_path_attachment.tfdemo.id
  side  = "B"
  addr  = var.l3outVpcSideB
}

resource "aci_external_network_instance_profile" "tfdemo" {
    l3_outside_dn  = aci_l3_outside.tfdemo.id
    description    = "from terraform"
    name           = "tfdemoExtEpg" 
    relation_fv_rs_prov = [ aci_contract.epg_l3out_contract.id ]
    relation_fv_rs_cons = [ aci_contract.epg_l3out_contract.id ]
}


resource "aci_l3_ext_subnet" "tfdemo" {
    external_network_instance_profile_dn  = aci_external_network_instance_profile.tfdemo.id
    description                           = "tfdemo L3 External subnet"
    ip                                    = "0.0.0.0/0"
}

# configure subnet under epg3 using rest
resource "aci_rest" "epg3subnet" {
    path       = "/api/node/mo/uni/tn-demo/ap-ap1/epg-epg3.json"
    payload = <<EOF
        {
			"fvSubnet": {
				"attributes": {
					"annotation": "",
					"ctrl": "",
					"descr": "",
					"dn": "uni/tn-demo/ap-ap1/epg-epg3/subnet-[172.16.1.254/24]",
					"ip": "172.16.1.254/24",
					"ipDPLearning": "enabled",
					"name": "",
					"nameAlias": "",
					"preferred": "no",
					"scope": "public,shared",
					"userdom": ":all:",
					"virtual": "no"
				}
			}
		}
  EOF
    depends_on = [
    aci_application_epg.epg3
  ]
}