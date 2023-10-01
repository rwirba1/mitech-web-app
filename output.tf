output "instance_public_ip" {
  value = aws_instance.demo_app.public_ip
}
output "s3_name" {
  value = aws_s3_bucket.name
}
output "s3_arn" {
  value = aws_s3_bucket.arn
}