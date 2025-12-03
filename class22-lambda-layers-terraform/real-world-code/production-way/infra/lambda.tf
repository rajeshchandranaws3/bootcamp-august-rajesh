# Create a KMS key for s3 bucket encryption
resource "aws_kms_key" "s3_bucket_key" {
  description             = "KMS key for S3 bucket encryption"
  deletion_window_in_days = 10

  tags = {
    Name = "${var.environment}-s3-bucket-key"
  }
}


# Bucket to store lambda code(artifact)

module "lambda_s3_bucket" {
  source       = "./modules/s3"
  bucket_name  = "${var.environment}-lambda-bucket-307946636515"
  if_encrypted = true
  if_versioning = true
  kms_key_arn  = aws_kms_key.s3_bucket_key.arn
  log_bucket   = "${var.environment}-log-bucket-307946636515"
}

# bucket = module.lambda_s3_bucket.bucket_name
# module.name_you_have_used.output_name_from_source_module
  

# lambda layers

module "lambda_layer" {
  for_each = local.lambda_layers_map
  source   = "terraform-aws-modules/lambda/aws"
  version = "8.1.0"

  create_layer = true

  layer_name          = each.key
  compatible_runtimes = each.value.compatible_runtimes
  runtime             = "python3.12"

  source_path = {
    path             = "${path.module}/${each.value.path}",
    pip_requirements = true,
    prefix_in_zip    = "python"
  }
  store_on_s3 = true
  s3_bucket   = module.lambda_s3_bucket.bucket_name
}

# module.lambda_layer_s3.lambda_layer_arn
# module.lambda_layer_s3[layer1].lambda_layer_arn


module "lambda_function" {
  for_each = local.lambda_info_map
  source   = "terraform-aws-modules/lambda/aws"
  version = "8.1.0"

  function_name = each.value.name
  handler       = each.value.handler
  runtime       = each.value.runtime
  publish       = true  
#   layers = [ module.layer[each.value.layers].lambda_layer_arn ]
  layers = [for layer_name in each.value.layers : module.lambda_layer[layer_name].lambda_layer_arn ]
  timeout       = 60
  store_on_s3 = true
  s3_bucket   = module.lambda_s3_bucket.bucket_name

  source_path = each.value.path
  environment_variables = each.value.environments_variables

  tags = {
    repo = "august-bootcamp"
  }
}