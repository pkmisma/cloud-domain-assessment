
# Creating VPC and Subnets

resource "aws_vpc" "my-vpc" {
    cidr_block = "10.0.0.0/16"
    enable_dns_support = "true" #gives you an internal domain name
    enable_dns_hostnames = "true" #gives you an internal host name
    instance_tenancy = "default"   
}

resource "aws_subnet" "subnet-public-1" {
    vpc_id = "${aws_vpc.my-vpc.id}"
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = "true" //it makes this a public subnet
    availability_zone = "us-east-1a"

}

# Create Internet Gateway

resource "aws_internet_gateway" "iac-igw" {
    vpc_id = "${aws_vpc.my-vpc.id}"
  
}

# Create the CRT

resource "aws_route_table" "public-crt" {
    vpc_id = "${aws_vpc.my-vpc.id}"
    
    route {
        //associated subnet can reach everywhere
        cidr_block = "0.0.0.0/0" 
        //CRT uses this IGW to reach internet
        gateway_id = "${aws_internet_gateway.iac-igw.id}" 
    }
    
}

resource "aws_route_table_association" "crta-public-subnet-1"{
    subnet_id = "${aws_subnet.subnet-public-1.id}"
    route_table_id = "${aws_route_table.public-crt.id}"
}

resource "aws_security_group" "alb" {
  name        = "terraform_alb_security_group"
  description = "Terraform load balancer security group"
  vpc_id      = "${aws_vpc.my-vpc.id}"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group" "project-iac-sg" {
  name = lookup(var.awsprops, "secgroupname")
  description = lookup(var.awsprops, "secgroupname")
  vpc_id = "${aws_vpc.my-vpc.id}"

  // To Allow HTTP Traffic
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
  depends_on = [
    aws_security_group.alb
  ]
}


resource "aws_instance" "project-iac" {
  ami = lookup(var.awsprops, "ami")
  instance_type = lookup(var.awsprops, "itype")
  subnet_id = "${aws_subnet.subnet-public-1.id}" 
  associate_public_ip_address = lookup(var.awsprops, "publicip")
  key_name = lookup(var.awsprops, "keyname")


  vpc_security_group_ids = [
    aws_security_group.project-iac-sg.id
  ]
  root_block_device {
    delete_on_termination = true
    volume_size = 20
    volume_type = "gp2"
    encrypted  = true
  }
  tags = {
    Name ="web-server"
    Environment = "DEV"
    OS = "UBUNTU"
    Managed = "IAC"
  }

  depends_on = [ aws_security_group.project-iac-sg ]
}


output "ec2instance" {
  value = aws_instance.project-iac.public_ip
}

resource "aws_s3_bucket" "log_bucket" {
  bucket = "my-log-bucket"
  acl    = "private"

  versioning {
    enabled = true
  }
}


resource "aws_lb" "sample_lb" {
    name = lookup(var.alb, "alb_names")
    internal           = false
    load_balancer_type = "application" 
    security_groups    = ["${aws_security_group.alb.id}"]
    enable_cross_zone_load_balancing = "true"

    enable_deletion_protection = true

  access_logs {
    bucket  = aws_s3_bucket.log_bucket.bucket
    prefix  = "app-lb"
    enabled = true
  }

    tags = {
         Environment = "testing"
         Role        = "Sample-Application"
    }

    depends_on = [ aws_security_group.alb ]
}


resource "aws_lb_target_group" "sample_tg" {
  name     = "tf-example-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.my-vpc.id}"
}

resource "aws_lb_target_group_attachment" "tg_attachment_test" {
    target_group_arn = aws_lb_target_group.sample_tg.arn
    target_id        = aws_instance.project-iac.id
    port             = 80
}


resource "aws_lb_listener" "lb_listner_https_test" {
  load_balancer_arn = aws_lb.sample_lb.id
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:acm:us-east-1:556861710053:certificate/28d7d75c-cb33-4f56-b1db-aa5888ad42ca"
  default_action {
     type             = "forward"
     target_group_arn = aws_lb_target_group.sample_tg.arn
  }
}

# generate inventory file for Ansible
resource "local_file" "new_var_file" {
    content  = "aws_instance.project-iac.public_ip"
    filename = "/var/lib/jenkins/workspace/Web-server-pipelin/Ansible/inventory"
}




