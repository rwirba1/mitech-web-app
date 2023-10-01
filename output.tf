output "instance_public_ip" {
  value = aws_instance.demo_app.public_ip
}