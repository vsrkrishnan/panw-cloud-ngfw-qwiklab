
region              = "us-west-1"               # Modify the region as required. Defaults to N. California region.
ssh-key-name        = "qwikLABS-??????-??????"  # Modify the SSH Key name to SSH Key to the one that you have created for your access. For QwikLab related access, please use the SSH Key that was generated by QwikLab.
prefix-name-tag     = "cngfw-"                  # Feel free to modify this if required. This prefix is just meant to make the lab resources identifiable

global_tags         = {
  # The tags added below are specific to Palo Alto Networks. You can modify the tags as applicable for your use-case.
  managedBy   = "Terraform"
  application = "Palo Alto Networks Cloud NGFW"
  owner       = "Palo Alto Networks - Software NGFW Products Team"
}