terraform {
  backend "s3" {
    bucket         = "goatfarm-terraform-state-dev"     # your backend bucket name
    key            = "dev/terraform.tfstate"              # path inside the bucket
    region         = "ap-south-1"
    encrypt        = true
  }
}
