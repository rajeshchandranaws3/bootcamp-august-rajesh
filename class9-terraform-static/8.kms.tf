# Create the KMS key
resource "aws_kms_key" "rds_kms" {
  description             = "KMS key - RDS encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

# Create an alias for easier reference
resource "aws_kms_alias" "rds_kms_alias" {
  name          = "alias/rds-encryption-key"
  target_key_id = aws_kms_key.rds_kms.key_id
}

