
####################################################################################
# Variables
variable compartment_root {
   default = "ocid1.tenancy.oc1..aaaaaaaao7ju5o6l4qt4vq2hpwulmcf26uf366wirsh6tam2bn7b2tdvehta"
}

variable resource_tags {
    type = map
    default ={}
}

variable availability_domains {
  type = map
  default = {}
}

variable environment { default="Proof of Concept"}

locals {
    required_tags ={
        environment = var.environment,
        # launch-id = uuidv5("oid",timestamp()),
        slack = "ecoyle",
        "email" = "edwin.coyle@oracle.com",
        "ops"   = "terraform",
        "Purpose"= "Ava Labs Validator Testing"
        "Lifecycle" = "temporary"
        }
    tags = merge(var.resource_tags, local.required_tags)
    region_number = 4
    }

variable compartment_sub    {default="govmod"}
variable cidr_block         { default="10.0.0.0/16"}
variable region             {default="us-ashburn-1"}

variable "node_image" {
  type = map
  default = {
    "ap-mumbai-1" 	    = "ocid1.image.oc1.ap-mumbai-1.aaaaaaaajkpc2zuhwpfj5qpijwlttk2o5ejp4v2bendemileaauuapfnsxpa"
    "ca-montreal-1"	    = "ocid1.image.oc1.ca-montreal-1.aaaaaaaavq3vkhncwwqwih5gs3hs3sfgb7wma2l7t7m6puzmliykrhmozmc"
    "ca-toronto-1"      = "ocid1.image.oc1.ca-toronto-1.aaaaaaaah7rpiczxdgsjmtmjcttqvvzggx2hefmergatx7cghamrs5prjzjq"
    "uk-london-1"       = "ocid1.image.oc1.uk-london-1.aaaaaaaalgdbxwctnjjtjona6fo3dhrhxifefzeulhy4rkav3bjmmp5gv63a"
    "us-ashburn-1"      = "ocid1.image.oc1.iad.aaaaaaaacmdv7wm2hz6lip3qbss5jh4ce2cg62bkusnha6kdoos3i6mmip7q"
    "us-phoenix-1"      = "ocid1.image.oc1.phx.aaaaaaaacm3mx4dociek46sqqwunrjikyaoqg5r2zb4kwhfyddd4l35cykna"
    "us-sanjose-1"      = "ocid1.image.oc1.us-sanjose-1.aaaaaaaa2drofemuz2rhe2obyram2ufizduzfynwlyggqtw7zhm6jn334zyq"
 }
}

output "image-id-static-list" {
  value = lookup(var.node_image, var.region, "error finding region, check Image Exists")
}

output "region-static-variable" {
  value = var.region
}

variable "lookup_region" {
    type = map
    default = {
        "1"="us-ashburn-1"
        "2"="us-chicago-1"
        "3"="us-phoenix-1"
        "4"="us-sanjose-1"
        "5"="ca-montreal-1"
        "6"="ca-toronto-1"
        "7"="uk-cardiff-1"
        "8"="uk-london-1"
        "9"="eu-amsterdam-1"
        "10"="eu-frankfurt-1"
        "11"="eu-madrid-1"
        "12"="eu-marseille-1"
        "13"="eu-milan-1"
        "14"="eu-paris-1"
        "15"="eu-stockholm-1"
        "16"="eu-zurich-1"
        "17"="ap-osaka-1"
        "18"="ap-seoul-1"
        "19"="ap-singapore-1"
        "20"="ap-tokyo-1"
        "21"="ap-sydney-1"
        "22"="ap-melbourne-1"
        "23"="sa-santiago-1"
        "24"="sa-saopaulo-1"
        "25"="sa-vinhedo-1"
        "26"="mx-queretaro-1"
        "27"="af-johannesburg-1"
        "28"="ap-chuncheon-1"
        "29"="ap-hyderabad-1"
        "30"="ap-mumbai-1"
        "31"="il-jerusalem-1"
        "32"="me-abudhabi-1"
        "33"="me-dubai-1"
        "34"="me-jeddah-1"
    }
}

output region-lookup {
    value = lookup(var.lookup_region,local.region_number,"unknown region - review setup")
}