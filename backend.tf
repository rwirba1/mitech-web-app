terraform {
  backend "s3" {
    bucket = "demo-bucket-20231001"
    key    = "demo-terraform-state"
    region = "us-east-1"
  }
}
