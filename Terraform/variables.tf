variable "AWS_REGION" {    
    default = "us-east-1"
}

variable "awsprops" {
    type = map
    default = {
    region = "us-east-1"
    vpc = "vpc-066ec79e503c40324"
    ami = "ami-0a6b2839d44d781b2"
    itype = "t2.micro"
    subnet = "subnet-0bb7101f9d2e5390b"
    publicip = true
    keyname = "kk"
    secgroupname = "webserver-Sec-Group"
  }
}


variable "alb" {
    type = map
    default = {
    alb_names = "test"
    vpc_id = "vpc-066ec79e503c40324"
  }
}

variable "subnets" {
    type = list
    default = ["subnet-0bb7101f9d2e5390b","subnet-02caf61fc1a43e7e7","subnet-032b9d85cfe389102"]
}


