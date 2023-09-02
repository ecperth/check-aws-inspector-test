terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
	backend "s3" {
    bucket 	= "amazon-inspector-check-test-tf-state"
		key 		= "state"
    region 	= "ap-southeast-2"
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "ap-southeast-2"
}

resource "aws_ecr_repository" "amazon_inspector_check_test" {
  name                 = "amazon-inspector-check-test"
  image_tag_mutability = "MUTABLE"
}

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = ["1c58a3a8518e8759bf075b76b750d4f2df264fcd"]
}

data "aws_iam_policy_document" "github_iam_policy_document" {
 	statement {
  	effect  = "Allow"
   	actions = ["sts:AssumeRoleWithWebIdentity"]
   	principals {
     	type        = "Federated"
     	identifiers = [aws_iam_openid_connect_provider.github.arn]
   	}
   	condition {
    	test     = "StringLike"
 			variable = "token.actions.githubusercontent.com:sub"
     	values   = ["repo:ecperth/amazon-inspector-check-test:*"]
   	}
 	}
}

resource "aws_iam_role" "github_iam_role" {
 name               = "github-iam-role"
 assume_role_policy = data.aws_iam_policy_document.github_iam_policy_document.json
}

data "aws_iam_policy_document" "github_role_ecr_policy_document" {
  statement {
		sid 			= "AllowEcrGetAuthorizationToken"
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }
	statement {
		sid 			= "AllowEcrRepoAccess"
    effect    = "Allow"
    actions   = ["ecr:*"]
    resources = [aws_ecr_repository.amazon_inspector_check_test.arn]
  }
}

resource "aws_iam_policy" "github_role_ecr_policy" {
  name        = "github-role-ecr-policy"
  description = "Policy granting github role access to ecr resources"
  policy      = data.aws_iam_policy_document.github_role_ecr_policy_document.json
}

resource "aws_iam_policy_attachment" "github_role_ecr_policy_attachment" {
  name       = "github-role-ecr-policy-attachment"
  roles      = [aws_iam_role.github_iam_role.name]
  policy_arn = aws_iam_policy.github_role_ecr_policy.arn
}