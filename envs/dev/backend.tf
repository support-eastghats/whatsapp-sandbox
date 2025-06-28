terraform {
  backend "s3" {
    bucket         = "eastghatscxllp-whatsapp-sandbox-tf-state"     # your backend bucket name
    key            = "dev/terraform.tfstate"              # path inside the bucket
    region         = "eu-north-1"
    encrypt        = true
  }
}
