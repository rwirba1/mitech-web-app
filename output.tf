output "instance_public_ip" {
  value = aws_instance.demo_app.public_ip
}
output "aws_s3_bucket_name" {
  value = aws_s3_bucket.name
}
output "aws_s3_bucket_arn" {
  value = aws_s3_bucket.arn
}