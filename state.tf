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

  required_version = "~> 1.3.7"

  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.35.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.5"
    }
  }
}

