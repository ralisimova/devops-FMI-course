provider "aws" {
  region = "eu-north-1"
}

data "external" "home" {
  program = ["sh", "-c", "echo '{\"value\":\"'$HOME'\"}'"]
}

resource "aws_key_pair" "ansible_key_pair" {
  key_name   = "ansible_key_pair"
  public_key = tls_private_key.ansible_key.public_key_openssh
}

resource "aws_instance" "webservers" {
  
  ami           = "ami-0abaed814109888a5"
  instance_type = "t3.micro"
  security_groups = [ aws_security_group.allow_web_traffic.name ]

  # Reference ansible key pair
  key_name = aws_key_pair.ansible_key_pair.key_name
  user_data = file("${path.module}/resources/user_data.sh")

  tags = {
    Name = "Project"
    Role = "webserver"
    Public = "true"
  }
}

resource "aws_security_group" "allow_web_traffic" {
  name        = "allow_web_traffic"
  description = "Allow inbound web traffic"

  ingress {
    description = "TLS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_web_traffic"
  }
}

output webservers {
  value = aws_instance.webservers.*.public_dns
}