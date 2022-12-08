
# Creating VPC and Subnets

resource "aws_vpc" "my-vpc" {
    cidr_block = "10.0.0.0/16"
    enable_dns_support = "true" #gives you an internal domain name
    enable_dns_hostnames = "true" #gives you an internal host name
    instance_tenancy = "default"   
}

resource "aws_subnet" "subnet-public" {
    vpc_id = "${aws_vpc.my-vpc.id}"
    count = length(var.public_subnet_cidrs)
    availability_zone       = "${var.aws_region}${var.zones[count.index]}"
    cidr_block              = var.public_subnet_cidrs[count.index]
    map_public_ip_on_launch = "true" //it makes this a public subnet
}

resource "aws_subnet" "subnet-webserver" {
    vpc_id = "${aws_vpc.my-vpc.id}"
    availability_zone       = "us-east-1a"
    cidr_block = "10.0.3.0/27"
    map_public_ip_on_launch = "true" //it makes this a public subnet
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
    count = length(var.public_subnet_cidrs)
    subnet_id      = element(aws_subnet.subnet-public.*.id, count.index)
    route_table_id = "${aws_route_table.public-crt.id}"
}

resource "aws_route_table_association" "crta-public-subnet-2"{
    subnet_id      = "${aws_subnet.subnet-webserver.id}"
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

resource "aws_security_group" "webserver-sg" {
  name = lookup(var.awsprops, "secgroupname")
  description = lookup(var.awsprops, "secgroupname")
  vpc_id = "${aws_vpc.my-vpc.id}"

  // To Allow HTTP Traffic
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    security_groups = ["sg-041196b434e363a95"]
  }

  ingress {
    from_port = 443
    protocol = "tcp"
    to_port = 443
    security_groups = ["${aws_security_group.alb.id}"]
  }

  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    security_groups = ["${aws_security_group.alb.id}"]
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
  subnet_id = "${aws_subnet.subnet-webserver.id}" 
  associate_public_ip_address = lookup(var.awsprops, "publicip")
  key_name = lookup(var.awsprops, "keyname")


  vpc_security_group_ids = [
    aws_security_group.webserver-sg.id
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

  depends_on = [ aws_security_group.webserver-sg ]
}


output "ec2instance" {
  value = aws_instance.project-iac.public_ip
}



resource "aws_s3_bucket" "log_bucket" {
  bucket = "my-app-loysareq-bucket"
}

resource "aws_s3_bucket_acl" "log_bucket-acl" {
  bucket = aws_s3_bucket.log_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "versioning_enable" {
  bucket = aws_s3_bucket.log_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}


data "aws_iam_policy_document" "allow-lb" {
  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:s3:::my-app-loysareq-bucket/app-lb/AWSLogs/844298705625/*"]
    actions   = ["s3:PutObject"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::127311923021:root"]
    }
  }
}

resource "aws_s3_bucket_policy" "allow-lb" {
  bucket = aws_s3_bucket.log_bucket.id
  policy = data.aws_iam_policy_document.allow-lb.json
}


resource "aws_lb" "sample_lb" {
    name = lookup(var.alb, "alb_names")
    internal           = false
    load_balancer_type = "application" 
    security_groups    = ["${aws_security_group.alb.id}"]
    subnets = aws_subnet.subnet-public.*.id
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

output "lb_dns_name" {
  description = "The DNS name of the application load balancer"
  value       = aws_lb.sample_lb.dns_name
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
  certificate_arn   = "arn:aws:acm:us-east-1:844298705625:certificate/f7c634c0-0ea2-4676-b7d6-097bac47870b"
  default_action {
     type             = "forward"
     target_group_arn = aws_lb_target_group.sample_tg.arn
  }
}

# generate inventory file for Ansible
resource "local_file" "new_var_file" {
    content  = "${aws_instance.project-iac.public_ip}"
    filename = "/var/lib/jenkins/workspace/Web-server-pipeline/Ansible/inventory"
}





