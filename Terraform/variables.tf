variable "aws_region" {    
    default = "us-east-1"
}

variable "awsprops" {
    type = map
    default = {
    region = "us-east-1"
    vpc = "vpc-066ec79e503c40324"
    ami = "ami-0a6b2839d44d781b2"
    itype = "t2.micro"
    publicip = true
    secgroupname = "webserver-Sec-Group"
    keyname = "kk"
  }
}

variable "alb" {
    type = map
    default = {
    alb_names = "test"
    vpc_id = "vpc-066ec79e503c40324"
  }
}

variable "public_subnet_cidrs" {
  type    = list(any)
  default = ["10.0.1.0/24", "10.0.2.0/26"]
}

variable "zones" {
  type    = list(any)
  default = ["a", "b"]
}
