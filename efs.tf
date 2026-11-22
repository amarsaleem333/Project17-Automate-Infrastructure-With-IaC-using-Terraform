# create key from key management system (KMS is supported in Community)
resource "aws_kms_key" "ACS-kms" {
  description = "KMS key"
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "kms-key-policy"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::000000000000:root"
        }
        Action   = "kms:*"
        Resource = "*"
      }
    ]
  })
}

# create key alias
resource "aws_kms_alias" "alias" {
  name          = "alias/kms"
  target_key_id = aws_kms_key.ACS-kms.id
}

