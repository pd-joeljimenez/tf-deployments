// -----------------------------
// Backend
// -----------------------------

terraform {
  backend "s3" {

    key = "global/aqua.tfstate"

    region         = "us-west-2"
    bucket         = "aqua-backend"
    dynamodb_table = "aqua-backend-locks"
    encrypt        = true
  }

}

