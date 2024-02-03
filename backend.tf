// --------------------------------------------------
// vArmour Backend Resources
// --------------------------------------------------

resource "aws_s3_bucket" "backend_state" {
  bucket = "aqua-backend"
  tags = {
    bucket        = "aqua-backend"
    Environment = "Lab"
    Owner       = "Joel Jimenez"
    Team        = "Infrastructure"
  }
}

resource "aws_dynamodb_table" "backend_lock" {
  name = "aqua-backend-locks"

  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Environment = "Lab"
    Owner       = "Joel Jimenez"
    Team        = "Infrastructure"
  }
}