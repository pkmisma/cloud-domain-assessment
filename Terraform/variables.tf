variable "awsprops" {
    type = map
    default = {
    region = "us-east-1"
    vpc = "vpc-0ecfb893982a19147"
    ami = "ami-0a6b2839d44d781b2"
    itype = "t2.micro"
    subnet = "subnet-08baa8516d7636660"
    publicip = true
    keyname = "aws-key"
    secgroupname = "webserver-Sec-Group"
  }
}