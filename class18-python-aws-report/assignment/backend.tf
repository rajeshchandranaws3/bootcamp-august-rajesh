# remote backend
terraform {
  backend "s3" {
    bucket  = "state-bucket-307946636515"
    key     = "august-bootcamp/lambda-function/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}