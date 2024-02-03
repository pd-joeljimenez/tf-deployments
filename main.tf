provider "aws" {
  region = "us-west-2"

  default_tags {
    tags = {
      Environment = "Lab"
      Owner       = "Joel Jimenez"
      Team        = "Infrastructure"
    }
  }
}

module "aws_ec2" {
  source = "../tf-modules/aws_ec2"
  #source = "github.com/pd-joeljimenez/tf-modules//aws_ec2?ref=(GIT_COMMIT_ID)"

  deployment_name    = "aqua-homework"
  ami_filter         = "amzn2-ami-hvm*-x86_64-ebs"
  instance_type      = "t3.micro"
  vpc_id             = module.aws_vpc.vpc.id
  public_subnets     = module.aws_vpc.public_subnets
  private_subnets    = module.aws_vpc.private_subnets
  min_size           = 1
  max_size           = 1
  desired_capacity   = 1
  private_subnet_ids = [for s in module.aws_vpc.private_subnets : s.id]
  public_subnet_ids  = [for s in module.aws_vpc.public_subnets : s.id]
  linux_user_data    = <<-EOF
    #!/bin/bash
    set -x
    sudo yum update -y
    sudo amazon-linux-extras install nginx1 -y
    sudo systemctl enable nginx
    sudo systemctl start nginx
  EOF
  security_group_ids = module.aws_securitygroup.security_group_ids
  security_group_names = module.aws_securitygroup.security_group_names
}

module "aws_vpc" {
  #source = "github.com/pd-joeljimenez/tf-modules//aws_vpc?ref=(GIT_COMMIT_ID)"
  source = "../tf-modules/aws_vpc"

  deployment_name = "aqua-homework"
  vpc_region      = "us-west-2"
  cidr_block      = "10.10.0.0/16"
  public_subnets = {
    "us-west-2a" = "10.10.0.0/20",
    "us-west-2b" = "10.10.32.0/20"
  }
  private_subnets = {
    "us-west-2a" = "10.10.128.0/20",
    "us-west-2b" = "10.10.160.0/20"
  }
  security_group_ids = module.aws_securitygroup.security_group_ids
  security_group_names = module.aws_securitygroup.security_group_names
}

module "aws_securitygroup" {
  source = "../tf-modules/aws_securitygroup"

  security_groups = [
    {
      //Alb
      sg_name        = "alb-sg-aqua-homework"
      sg_description = "HTTP access from external"
      vpc_id         = module.aws_vpc.vpc.id
      ingress_rules  = [
        {
          from_port          = 80
          to_port            = 80
          protocol           = "tcp"
          cidr_blocks        = ["0.0.0.0/0"]
          self               = true
        },
      ]
      egress_rules   = [
        {
          from_port          = 0
          to_port            = 0
          protocol           = "-1"
          cidr_blocks        = ["0.0.0.0/0"]
        },
      ]
    },
    {
      // Launch Template (EC2)
      sg_name        = "ec2-lt-sg-aqua-homework"
      sg_description = "EC2 launch template sg"
      vpc_id         = module.aws_vpc.vpc.id
      ingress_rules  = [
        {
          from_port          = 80
          to_port            = 80
          protocol           = "tcp"
          cidr_blocks        = ["10.10.0.0/16"]
          self               = true
        },
        {
          from_port          = 22
          to_port            = 22
          protocol           = "tcp"
          cidr_blocks        = ["10.10.0.0/16"]
          self               = true
        },
      ]
      egress_rules   = [
        {
          from_port          = 0
          to_port            = 0
          protocol           = "-1"
          cidr_blocks        = ["0.0.0.0/0"]
        },
      ]
    },
  ]
}


output security_group_ids {
  value = module.aws_securitygroup.security_group_ids
}

output security_group_names {
  value = module.aws_securitygroup.security_group_names
}

output private_subnets {
  value = module.aws_vpc.private_subnets
}

output public_subnets {
  value = module.aws_vpc.public_subnets
}

output vpc {
  value = module.aws_vpc.vpc
}
