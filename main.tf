# Create a tenant
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

# create service bd
resource "aci_bridge_domain" "bdSvc" {
    tenant_dn = aci_tenant.tfTenant.id
    relation_fv_rs_ctx = aci_vrf.vrf1.id
    description = "bd for service node"
    name = var.bdSvc
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

# create subnet for bd service
resource "aci_subnet" "bdSvcSubnet" {
    parent_dn = aci_bridge_domain.bdSvc.id
    ip = var.bdSvcSubnet
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

# Configure subnet under epg3, for inter-vrf use case between epg1 and epg3
resource "aci_subnet" "epg3Subnet" {
    parent_dn     = aci_application_epg.epg3.id
    ip            = "172.16.1.254/24"
    scope         = ["public","shared"]
    description   = "This subnet is created by terraform"
    ctrl          = ["no-default-gateway"]
    preferred     = "no"
    virtual       = "no"
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

# epg2 to physical domain 
resource "aci_epg_to_domain" "epg2" {
    application_epg_dn    = aci_application_epg.epg2.id
    tdn                   = data.aci_physical_domain.insbu_phys.id
}


# epg static path binding
resource "aci_epg_to_static_path" "epg1-1" {
    application_epg_dn  = aci_application_epg.epg1.id
    tdn  = "topology/pod-1/paths-101/pathep-[eth1/18]"
    encap  = var.encap-vlan-1911
    instr_imedcy = "lazy"
    mode  = "regular"
}

resource "aci_epg_to_static_path" "epg1-2" {
    application_epg_dn  = aci_application_epg.epg1.id
    tdn  = "topology/pod-1/paths-102/pathep-[eth1/18]"
    encap  = var.encap-vlan-1911
    instr_imedcy = "lazy"
    mode  = "regular"
}

resource "aci_epg_to_static_path" "epg2-1" {
    application_epg_dn  = aci_application_epg.epg2.id
    tdn  = "topology/pod-1/paths-101/pathep-[eth1/18]"
    encap  = var.encap-vlan-1912
    instr_imedcy = "lazy"
    mode  = "regular"
}

resource "aci_epg_to_static_path" "epg2-2" {
    application_epg_dn  = aci_application_epg.epg2.id
    tdn  = "topology/pod-1/paths-102/pathep-[eth1/18]"
    encap  = var.encap-vlan-1912
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

# Create l3out with OSPF 
resource "aci_l3out_ospf_external_policy" "tfdemo" {
    l3_outside_dn  = aci_l3_outside.tfdemo.id
    description    = "from terraform"
    area_cost      = "1"
    area_ctrl      = ["redistribute", "summary"]
    area_id        = "0.0.0.0"
    area_type      = "regular"
    multipod_internal = "no"
}

# create node profile
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

# create interface profile
resource "aci_logical_interface_profile" "tfdemo_interface_profile" {
    logical_node_profile_dn = aci_logical_node_profile.tfdemo_nodeProfile.id
    description             = "tfdemo logical interface profile"
    name                    = "tfdemo_int_prof"    
    prio                    = "unspecified"

}

# create ospf interface policy
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

# Create External EPG 
resource "aci_l3_ext_subnet" "tfdemo" {
    external_network_instance_profile_dn  = aci_external_network_instance_profile.tfdemo.id
    description                           = "tfdemo L3 External subnet"
    ip                                    = "0.0.0.0/0"
}


# Create l4-l7 device
resource "aci_l4_l7_device" "asav01" {
  tenant_dn                            = aci_tenant.tfTenant.id
  name                                 = var.fw01
  active                               = "no"
  context_aware                        = "single-Context"
  device_type                          = "VIRTUAL"
  function_type                        = "GoTo"
  is_copy                              = "no"
  mode                                 = "legacy-Mode"
  promiscuous_mode                     = "no"
  service_type                         = "FW"
  trunking                             = "no"
  relation_vns_rs_al_dev_to_dom_p {
    domain_dn      = "uni/vmmp-VMware/dom-POD1_ACI_DS"
    switching_mode = "native"
  }
}

# Create concrete device
resource "aci_concrete_device" "asav01" {
    l4_l7_device_dn   = aci_l4_l7_device.asav01.id
    name              = var.fw01
    vmm_controller_dn = "uni/vmmp-VMware/dom-POD1_ACI_DS/ctrlr-HNI05-Vcenter"
    vm_name           = var.fw01
}

# Create concrete interface
resource "aci_concrete_interface" "onearm" {
    concrete_device_dn            = aci_concrete_device.asav01.id
    name                          = "onearm"
    encap                         = "unknown"
    vnic_name                     = "Network adapter 2"
}

# Create logical interface (logical representation of conreate interface or group of concrete interfaces)
resource "aci_l4_l7_logical_interface" "onearm" {
    l4_l7_device_dn            = aci_l4_l7_device.asav01.id
    name                       = "onearm"
    relation_vns_rs_c_if_att_n = [aci_concrete_interface.onearm.id]
}

# Create service graph template
resource "aci_l4_l7_service_graph_template" "asav01" {
    tenant_dn                         = aci_tenant.tfTenant.id
    name                              = "asav01"
    description                       = "from terraform"
    l4_l7_service_graph_template_type = "legacy"
    ui_template_type                  = "UNSPECIFIED"
    term_prov_name                    = "T2"
    term_cons_name                    = "T1"
}

# Add function node to service graph template
resource "aci_function_node" "asav01" {
    l4_l7_service_graph_template_dn = aci_l4_l7_service_graph_template.asav01.id
    name                            = "N1"
    func_template_type              = "FW_ROUTED"
    func_type                       = "GoTo"
    managed                         = "no"
    routing_mode                    = "Redirect"
    sequence_number                 = "0"
    relation_vns_rs_node_to_l_dev   =  aci_l4_l7_device.asav01.id
    depends_on = [
        aci_l4_l7_device.asav01
    ]
  
}

resource "aci_connection" "conn1" {
  l4_l7_service_graph_template_dn  = aci_l4_l7_service_graph_template.asav01.id
  name  = "conn1"
  adj_type  = "L3"
  conn_dir  = "consumer"
  unicast_route  = "yes"
  relation_vns_rs_abs_connection_conns = [
    aci_l4_l7_service_graph_template.asav01.term_cons_dn,
    aci_function_node.asav01.conn_consumer_dn
  ]
}

resource "aci_connection" "conn2" {
  l4_l7_service_graph_template_dn  = aci_l4_l7_service_graph_template.asav01.id
  name  = "conn2"
  adj_type  = "L3"
  conn_dir  = "provider"
  unicast_route  = "yes"
  relation_vns_rs_abs_connection_conns = [
    aci_l4_l7_service_graph_template.asav01.term_prov_dn,
    aci_function_node.asav01.conn_provider_dn
  ]
}

# Create service redirect policy
resource "aci_service_redirect_policy" "asav01-onearm" {
  tenant_dn               = aci_tenant.tfTenant.id
  name                    = var.redirectPolName
}

# Add destination IP address to redirect policy
resource "aci_destination_of_redirected_traffic" "asav01-onearm" {
  service_redirect_policy_dn  = aci_service_redirect_policy.asav01-onearm.id
  ip                          = var.redirectIp
  mac                         = var.redirectMac
  description                 = "From Terraform"
}