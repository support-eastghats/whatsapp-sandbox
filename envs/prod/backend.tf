terraform {
  backend "s3" {
    bucket         = "eastghats-ccp-terraform-state-prod"     # your backend bucket name
    key            = "prod/terraform.tfstate"              # path inside the bucket
    region         = "ap-south-1"
    encrypt        = true
  }
}
