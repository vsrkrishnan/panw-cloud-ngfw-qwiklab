
attack-vpc = {
    name                 = "att-vpc"
    cidr_block           = "10.2.0.0/16"
    instance_tenancy     = "default"
    enable_dns_support   = true
    enable_dns_hostnames = true
    internet_gateway     = true
}

attack-vpc-route-tables = [
  { name = "rt", "subnet" = "subnet" }
]

attack-vpc-routes = {
  att-vpc-tgw = {
    name          = "att-vpc-tgw"
    vpc_name      = "att-vpc"
    route_table   = "rt"
    prefix        = "10.1.0.0/16"
    next_hop_type = "transit_gateway"
    next_hop_name = "tgw"
  },
  att-vpc-igw = {
    name          = "att-vpc-igw"
    vpc_name      = "att-vpc"
    route_table   = "rt"
    prefix        = "0.0.0.0/0"
    next_hop_type = "internet_gateway"
    next_hop_name = "att-vpc"
  }
}

attack-vpc-subnets = [
  { name = "subnet", cidr = "10.2.1.0/24", az = "a" },
  { name = "tgw-subnet", cidr = "10.2.0.0/24", az = "a" }
]

attack-vpc-instances = [
  {
    name          = "att-app-server"
    ami           = "ami-03fa4afc89e4a8a09"
    instance_type = "t2.micro"
    subnet        = "subnet"
  }
]