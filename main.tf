provider "aws" {
  region = "us-east-1" # Change this to your desired AWS region
}

resource "aws_s3_bucket" "demo-bucket" {
  bucket = "demo-bucket"
  acl = "private"
} 

resource "aws_security_group" "demo_sg" {
  name        = "demo_sg"
  description = "Allow all inbound traffic"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    ignore_changes = [name]
  }

  tags = {
    Name = "demo_sg"
  }
}

resource "aws_instance" "demo_web_server" {
  ami             = "ami-053b0d53c279acc90" # This AMI ID corresponds to Ubuntu 18.04 in us-west-2. Find the correct AMI for your desired Ubuntu version and region.
  instance_type   = "t2.micro" # Choose the desired instance type.
  security_groups = [aws_security_group.demo_sg.name]
  key_name        = "demokey" # Use the name of your EC2 Key Pair

  tags = {
    Name = "demo_web_server"
  }
}

output "instance_public_ip" {
  value = aws_instance.demo_web_server.public_ip
}
#

