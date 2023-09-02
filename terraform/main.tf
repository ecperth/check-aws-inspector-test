terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  backend "s3" {
    bucket = "check-aws-inspector-test-tf-state"
    key    = "state"
    region = "ap-southeast-2"
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "ap-southeast-2"
}

module "aws_github_oidc_iam_user" {
  source          = "./modules/aws_github_oidc_iam_user"
  thumbprint_list = ["1c58a3a8518e8759bf075b76b750d4f2df264fcd"]
  allowed_subs    = ["repo:ecperth/check-aws-inspector-test:*"]
}

module "aws_inspector_enabled_ecr" {
  source        = "./modules/aws_inspector_enabled_ecr"
  ecr_repo_name = "check-aws-inspector-test"
  ecr_role_name = module.aws_github_oidc_iam_user.iam_role.name
  ecr_role_arn  = module.aws_github_oidc_iam_user.iam_role.name
}
