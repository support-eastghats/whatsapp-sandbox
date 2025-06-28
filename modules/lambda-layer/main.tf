resource "aws_lambda_layer_version" "shared" {
  layer_name          = "whatsapp-common-layer"
  compatible_runtimes = ["nodejs18.x"]
  s3_bucket           = "eastghatscxllp-whatsapp-sandbox-shared-lambda-layer"
  s3_key              = "layers/shared-lambda-layer.zip"
  source_code_hash    = filebase64sha256("${path.module}/shared-lambda-layer.zip")
}
