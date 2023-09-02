//---OPENID---
resource "aws_iam_openid_connect_provider" "oidc" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = var.thumbprint_list
}

//---IAM---
data "aws_iam_policy_document" "iam_policy_document" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.oidc.arn]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = var.allowed_subs
    }
  }
}

resource "aws_iam_role" "iam_role" {
  name               = "github-iam-role"
  assume_role_policy = data.aws_iam_policy_document.iam_policy_document.json
}