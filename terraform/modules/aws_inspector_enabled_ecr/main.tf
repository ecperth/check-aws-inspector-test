//---ECR---
resource "aws_ecr_repository" "check_aws_inspector_test" {
  name                 = var.ecr_repo_name
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_registry_scanning_configuration" "scanning_config" {
  scan_type = "ENHANCED"

  rule {
    scan_frequency = "SCAN_ON_PUSH"
    repository_filter {
      filter      = aws_ecr_repository.check_aws_inspector_test.name
      filter_type = "WILDCARD"
    }
  }
}

data "aws_iam_policy_document" "role_ecr_policy_document" {
  statement {
    sid       = "AllowEcrGetAuthorizationToken"
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }
  statement {
    sid    = "AllowEcrRepoAccess"
    effect = "Allow"
    actions = [
      "ecr:CompleteLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:InitiateLayerUpload",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:DescribeImageScanFindings",
      "ecr:DescribeImages"
    ]
    resources = [aws_ecr_repository.check_aws_inspector_test.arn]
  }
  statement {
    sid       = "AllowAwsInspectAccess"
    effect    = "Allow"
    actions   = ["inspector2:ListCoverage", "inspector2:ListFindings"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "role_ecr_policy" {
  name        = "github-role-ecr-policy"
  description = "Policy granting github role access to ecr resources"
  policy      = data.aws_iam_policy_document.role_ecr_policy_document.json
}

resource "aws_iam_policy_attachment" "role_ecr_policy_attachment" {
  name       = "github-role-ecr-policy-attachment"
  roles      = ["${var.ecr_role_name}"]
  policy_arn = aws_iam_policy.role_ecr_policy.arn
}

//---AMAZON-INSPECT---
data "aws_caller_identity" "current" {}

resource "aws_inspector2_enabler" "enable_aws_inspector" {
  account_ids    = [data.aws_caller_identity.current.account_id]
  resource_types = ["ECR"]
}