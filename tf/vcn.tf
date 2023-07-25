/*Validator Node Testing*/


####################################################################################
# Provider

provider "oci" {
    region = var.region 
    alias   = "iad" 
    # tenancy_ocid = "" 
    # user_ocid = "" 
    # private_key = "" 
    # private_key_path = "" 
    # private_key_password = "" 
    # fingerprint = ""
    # config_file_profile = "" 
}

####################################################################################
# Data Sources

data "oci_identity_compartments" "sub" {
    #Required
    compartment_id = var.compartment_root
    name = var.compartment_sub
}

data "oci_identity_availability_domains" "ad" {
  compartment_id = data.oci_identity_compartments.sub.compartments.0.id
  depends_on = [
      data.oci_identity_compartments.sub
    ]
  }

data "oci_core_service_gateways" "gateways" {
    #Required
    compartment_id =  data.oci_identity_compartments.sub.compartments.0.id
    #Optional
    vcn_id = oci_core_virtual_network.mainnet.id
}

data "oci_core_services" "services" {
}
####################################################################################
# Network Create

resource "oci_core_virtual_network" "mainnet" {
  cidr_block     = "${var.cidr_block}"
  compartment_id = data.oci_identity_compartments.sub.compartments.0.id
  display_name   = "mainnet"
  dns_label      = "mainnet"
  is_ipv6enabled = true
  freeform_tags = local.tags
  }

  resource "oci_core_internet_gateway" "internet_gateway" {
  compartment_id = data.oci_identity_compartments.sub.compartments.0.id
  display_name   = "InternetGateway"
  vcn_id         = oci_core_virtual_network.mainnet.id
  freeform_tags = local.tags
  }

resource "oci_core_public_ip" "internet" {
  compartment_id = data.oci_identity_compartments.sub.compartments.0.id
  lifetime = "RESERVED"
}
resource "oci_core_nat_gateway" "nat_gateway" {
    #Required
    compartment_id = data.oci_identity_compartments.sub.compartments.0.id
    vcn_id = oci_core_virtual_network.mainnet.id
    #Optional
    block_traffic = false
    display_name = "nat_gateway"
    freeform_tags = local.tags
    public_ip_id = oci_core_public_ip.internet.id
}

resource "oci_core_service_gateway" "gateway" {
  #Required
  vcn_id = oci_core_virtual_network.mainnet.id
  compartment_id = data.oci_identity_compartments.sub.compartments.0.id
  services {
    service_id = data.oci_core_services.services.services[1].id
  }
}

 ##############################################################################
 ####    ROUTE TABLEs
 ##############################################################################

resource "oci_core_route_table" "public" {
  compartment_id = data.oci_identity_compartments.sub.compartments.0.id
  vcn_id         = oci_core_virtual_network.mainnet.id
  display_name   = "route-table-public"
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.internet_gateway.id
  }
}

resource "oci_core_route_table" "private" {
  compartment_id = data.oci_identity_compartments.sub.compartments.0.id
  vcn_id         = oci_core_virtual_network.mainnet.id
  display_name   = "route-table-private"
  route_rules {
    destination       =  "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.nat_gateway.id
  }
}

resource "oci_core_route_table" "service_gateway" {
  compartment_id = data.oci_identity_compartments.sub.compartments.0.id
  vcn_id         = oci_core_virtual_network.mainnet.id
  display_name   = "route-table-service-gateway"
  route_rules {
    destination       = data.oci_core_services.services.services[1].cidr_block
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.gateway.id
  }
}

# Security
#   security-lists.tf 
#   security-groups.tf 


variable cidrsubnet {default = 24}
variable cidrmask {default = 16}
resource "oci_core_subnet" "public" {
  count = length(data.oci_identity_availability_domains.ad.availability_domains.*.name)
  vcn_id            = oci_core_virtual_network.mainnet.id
  cidr_block = cidrsubnet(oci_core_virtual_network.mainnet.cidr_block,(var.cidrsubnet - var.cidrmask), (count.index+1))
  # availability_domain = data.oci_identity_availability_domains.ad.availability_domains[count.index].name
  prohibit_public_ip_on_vnic = false
  compartment_id = data.oci_identity_compartments.sub.compartments.0.id
  display_name = format("public-sn-%02s",(count.index+1))
  freeform_tags = {Name = format("public-sn-%02s",(count.index+1)), 
                  Type = "public",
                  NAT-primary = count.index == 0 ? true : false,
                  NAT-secondary = count.index == 1 ? true : false}
   route_table_id = oci_core_route_table.public.id
   #dns_label = "public"
   #security_list_ids = []
}


resource "oci_core_subnet" "private" {
  count = length(data.oci_identity_availability_domains.ad.availability_domains.*.name)
  vcn_id            = oci_core_virtual_network.mainnet.id
  cidr_block = cidrsubnet(oci_core_virtual_network.mainnet.cidr_block,(var.cidrsubnet - var.cidrmask),(255 - (length(data.oci_identity_availability_domains.ad.availability_domains.*.name)-count.index+1)))
  # availability_domain = data.oci_identity_availability_domains.ad.availability_domains[count.index].name
  prohibit_public_ip_on_vnic = true
  compartment_id = data.oci_identity_compartments.sub.compartments.0.id
  display_name = format("private-sn-%02s",(count.index+1))
  #dns_label = "private"
  freeform_tags = {Name = format("private-sn-%02s",(count.index+1)), 
                  Type = "public",
                  NAT-primary = count.index == 0 ? true : false,
                  NAT-secondary = count.index == 1 ? true : false}
  route_table_id = oci_core_route_table.private.id
}

/**/
# Compute



####################################################################################
# Output
output "ad_length" {
    value = length(data.oci_identity_availability_domains.ad) 
}

output "ad_names" {
    value = data.oci_identity_availability_domains.ad.availability_domains.*.name
}


/**/