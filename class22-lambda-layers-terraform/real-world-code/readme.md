# Terraform Module: Lambda Functions, Layers & Encrypted S3 Bucket

This Terraform configuration provisions:

- An **AWS KMS key** for encrypting S3 objects  
- An **S3 bucket** for storing Lambda artifacts (using a child S3 module)  
- **Lambda Layers** (using `terraform-aws-modules/lambda/aws`)  
- **Lambda Functions** that use the created layers and upload code to S3  

The module supports deploying multiple Lambda layers and functions dynamically using maps.

---

## Features

### ✔ Encrypted S3 Bucket  
- Dedicated AWS KMS key  
- Versioning enabled  
- Optional logging bucket  

### ✔ Lambda Layers  
- Created dynamically using `for_each`  
- Python dependency packaging via `pip_requirements = true`  
- Artifacts stored in S3  

### ✔ Lambda Functions  
- Deployed using official Lambda module  
- Layers attached dynamically  
- Code stored in S3  
- Supports environment variables  
- Publishes versions automatically  

---

## Architecture Overview

aws_kms_key.s3_bucket_key
│
▼
module.lambda_s3_bucket (S3 Bucket)
│
┌──────┴────────┐
▼ ▼
Lambda Layers Lambda Functions
module.lambda_layer[]
module.lambda_function[]


---

## Input Variables

Your configuration expects variables similar to:

| Variable | Description |
|---------|-------------|
| `environment` | Deployment environment (dev, prod, etc.) |
| `lambda_layers_map` | Map of Lambda layer definitions |
| `lambda_info_map` | Map of Lambda function definitions |

---

## Example: lambda_layers_map

```hcl
lambda_layers_map = {
  layer1 = {
    path                 = "layers/layer1"
    compatible_runtimes = ["python3.12"]
  }
  layer2 = {
    path                 = "layers/layer2"
    compatible_runtimes = ["python3.12"]
  }
}

lambda_info_map = {
  function1 = {
    name                  = "sample-function-1"
    handler               = "app.lambda_handler"
    runtime               = "python3.12"
    path                  = "src/function1"
    layers                = ["layer1"]
    environments_variables = {
      STAGE = "dev"
    }
  }
}

```

# Resources Created
## KMS

aws_kms_key.s3_bucket_key — used for S3 bucket encryption.

## S3 Bucket Module

Uses your child module under ./modules/s3:

Encrypted S3 bucket for Lambda artifacts

Versioning enabled

Logging bucket supported

## Lambda Layers

Created using terraform-aws-modules/lambda/aws

PIP requirements automatically packaged

Stored on S3

## Lambda Functions

Created using the same module

Layers dynamically attached from layer outputs

Environment variables supported

Code uploaded to S3

Version published

## Project Structure

```
.
├── main.tf                          # Primary resource definitions
├── variables.tf                     # Input variable declarations
├── outputs.tf                       # Output values
├── modules/
│   └── s3/                          # Child S3 module
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── layers/
│   └── layer1/                      # Lambda layer source
│       └── requirements.txt
└── src/
    └── function1/                   # Lambda function source
        └── app.py
```

### File Descriptions

| File | Purpose |
|------|---------|
| `main.tf` | KMS key, S3 bucket module, Lambda layers, and functions |
| `variables.tf` | Input variables for environment, layers, and functions |
| `outputs.tf` | Lambda ARNs, layer versions, and S3 bucket details |
| `modules/s3/` | Reusable S3 bucket module with encryption |
| `layers/layer1/` | Python dependencies for Lambda layer |
| `src/function1/` | Lambda function application code |

