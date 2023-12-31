provider "aws" {
  region = "us-east-1"
}

# Create an IAM User with Administrator permissions
resource "aws_iam_user" "admin_user" {
  name = "deployer"
}

resource "aws_iam_user_policy_attachment" "admin_policy_attachment" {
  user       = aws_iam_user.admin_user.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Create an IAM Role
resource "aws_iam_role" "ec2_role" {
  name = "deployerrole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

# Attach the AdministratorAccess policy to the IAM Role
resource "aws_iam_role_policy_attachment" "ec2_role_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role       = aws_iam_role.ec2_role.name
}

# Create a security group for the EC2 instance
resource "aws_security_group" "instance_sg" {
  name_prefix = "mt-web-prod-ue-1-sg"

  ingress {
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "22"
    to_port     = "22"
  }

  ingress {
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "80"
    to_port     = "80"
    security_groups = [aws_security_group.lb_sg.id]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
}
  tags = {
    Name = "mt-prod-instance_sg"
  }
}

# Create an IAM Instance Profile
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "deployer-instance-profile"
  role = aws_iam_role.ec2_role.name
}

# Create an EC2 instance and associate the IAM Role
resource "aws_instance" "ec2_instance" {
  ami           = "ami-0261755bbcb8c4a84"
  instance_type = "t2.micro"
  key_name      = "ryankey"

  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

  tags = {
    Name = "mt-web-prod-ue-1"
  }

  security_groups = [aws_security_group.instance_sg.name]
}

# Create an Application Load Balancer
resource "aws_lb" "mt-web-prod_lb" {
  name               = "mt-web-prod-lb"
  internal           = false
  load_balancer_type = "application"

  enable_deletion_protection = false

  subnets = ["subnet-098cf4ebc26256760", "subnet-0a08f7c244bab40a4", "subnet-09a37192949d9f8f6"]  # Specify your subnet IDs here
}

# Create a security group for the Load Balancer
resource "aws_security_group" "lb_sg" {
  name_prefix = "mt-web-prod-lb-sg"

  ingress {
    from_port   = 0
    to_port     = 65535
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
    Name = "mt-prod-lb-sg"

  }
}

# Create a target group for the Load Balancer
resource "aws_lb_target_group" "mt-web-prod-tg" {
  name     = "mt-web-prod-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "vpc-00e1890d94c4fcc63"  # Specify your VPC ID here

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 10
    path                = "/"
  }
}

# Register the EC2 instance with the target group
resource "aws_lb_target_group_attachment" "mt-web-prod_tg_attachment" {
  target_group_arn = aws_lb_target_group.mt-web-prod-tg.arn
  target_id        = aws_instance.ec2_instance.id
}

# Create an Application Load Balancer Listener
resource "aws_lb_listener" "mt-web-prod_lb_listener" {
  load_balancer_arn = aws_lb.mt-web-prod_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mt-web-prod-tg.arn
  }
}

output "instance_public_ip" {
  value = aws_instance.ec2_instance.public_ip
}
