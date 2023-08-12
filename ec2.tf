provider "aws" {
  region = "us-east-1" # Change this to your desired AWS region
}

resource "aws_security_group" "prod_sg_new" {
  name        = "prod_sg_new"
  description = "Allow inbound traffic on port 80 and 22"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Be cautious about allowing traffic from everywhere
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # For SSH. In production, restrict this to your IP or a specific range.
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
    Name = "prod_sg_new"
  }
}

resource "aws_instance" "prod_web_server" {
  ami             = "ami-053b0d53c279acc90" # This AMI ID corresponds to Ubuntu 18.04 in us-west-2. Find the correct AMI for your desired Ubuntu version and region.
  instance_type   = "t2.micro" # Choose the desired instance type.
  security_groups = [aws_security_group.prod_sg_new.name]
  key_name        = "mykey" # Use the name of your EC2 Key Pair

  tags = {
    Name = "prod_web_server"
  }
}

output "instance_public_ip" {
  value = aws_instance.prod_web_server.public_ip
}

