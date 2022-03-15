
region              = "ap-south-1"
prefix-name-tag     = "cngfw-"
ssh-key-name        = "my-key-pair"

global_tags         = {
  managedBy   = "Terraform"
  application = "Palo Alto Networks Cloud NGFW"
  owner       = "Palo Alto Networks - Software NGFW Products Team"
}