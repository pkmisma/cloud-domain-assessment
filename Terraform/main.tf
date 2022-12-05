

resource "aws_security_group" "project-iac-sg" {
  name = lookup(var.awsprops, "secgroupname")
  description = lookup(var.awsprops, "secgroupname")
  vpc_id = lookup(var.awsprops, "vpc")

  // To Allow HTTP Traffic
  ingress {
    from_port = 22
    protocol = "ssh"
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
}


resource "aws_instance" "project-iac" {
  ami = lookup(var.awsprops, "ami")
  instance_type = lookup(var.awsprops, "itype")
  subnet_id = lookup(var.awsprops, "subnet") 
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

resource "aws_lb" "sample_lb" {
    name = lookup(var.alb, "alb_names")
    internal           = false
    load_balancer_type = "application" 
    security_groups    = var.security_grp
    subnets            = var.subnets
    enable_cross_zone_load_balancing = "true"
    tags = {
         Environment = "testing"
         Role        = "Sample-Application"
    }
}


resource "aws_lb_target_group" "test" {
  name     = "tf-example-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = lookup(var.alb, "vpc_id")
}

resource "aws_lb_target_group_attachment"
"tg_attachment_test" {
    target_group_arn = aws_lb_target_group.sample_tg["test"].arn
    target_id        = "${aws_instance.project-iac.instance.id}"
    port             = 80
}


resource "aws_lb_listener" "lb_listner_https_test" {
  load_balancer_arn = aws_lb.sample_lb["test"].id
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:acm:us-east-1:387779321901:certificate/c3c682fc-3adb-43d7-a63b-d2d58156d0e4"
  default_action {
     type             = "forward"
     target_group_arn = aws_lb_target_group.sample_tg["test"].id
  }
}
