
vulnerable-vpc = {
  name                 = "vul-vpc"
  cidr_block           = "10.1.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  internet_gateway     = true
}

vulnerable-vpc-route-tables = [
  { name = "rt", "subnet" = "subnet" }
]

vulnerable-vpc-subnets = [
  { name = "subnet", cidr = "10.1.1.0/24", az = "a" },
  { name = "tgw-subnet", cidr = "10.1.0.0/24", az = "a" }
]

vulnerable-vpc-security-groups = [
  {
    name = "sg"
    rules = [
      {
        description = "Permit All traffic outbound"
        type        = "egress", from_port = "0", to_port = "0", protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      },
      {
        description = "Permit All Internal traffic"
        type        = "ingress", from_port = "0", to_port = "0", protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      },
      {
        description = "Permit Port 80 Public"
        type        = "ingress", from_port = "8080", to_port = "8080", protocol = "tcp"
        cidr_blocks = ["10.2.1.0/32"]
      },
      {
        description = "Permit Port 22 Public"
        type        = "ingress", from_port = "22", to_port = "22", protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]
  }
]

vulnerable-vpc-instances = [
  {
    name          = "vul-app-server"
    ami           = "ami-03fa4afc89e4a8a09"
    instance_type = "t2.micro"
    subnet        = "subnet"
  }
]

vulnerable-vpc-routes = {
  vul-vpc-igw = {
    name          = "vul-vpc-igw"
    vpc_name      = "vul-vpc"
    route_table   = "rt"
    prefix        = "0.0.0.0/0"
    next_hop_type = "internet_gateway"
    next_hop_name = "vul-vpc"
  },
  vul-vpc-tgw = {
    name          = "vul-vpc-tgw"
    vpc_name      = "vul-vpc"
    route_table   = "rt"
    prefix        = "10.2.0.0/16"
    next_hop_type = "transit_gateway"
    next_hop_name = "tgw"
  }
}