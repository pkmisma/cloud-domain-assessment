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
    publicip = true
    keyname = "aws-key"
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
    default = ["${aws_subnet.subnet-public-1.id}","${aws_subnet.subnet-public-2.id}]
}


