resource "aws_s3_bucket" "codebuild" {
 bucket = "deploy-apps-codebuild"
 acl    = "private"
}

resource "aws_iam_role" "deploy_apps" {
  name = "deploy_apps"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "deploy_apps" {
  role = aws_iam_role.deploy_apps.name

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateNetworkInterface",
        "ec2:DescribeDhcpOptions",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeVpcs"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateNetworkInterfacePermission"
      ],
      "Resource": [
        "arn:aws:ec2:us-east-1:123456789012:network-interface/*"
      ],
      "Condition": {
        "StringEquals": {
          "ec2:AuthorizedService": "codebuild.amazonaws.com"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ssm:Get*"
      ],
      "Resource": [
        ${aws_ssm_parameter.docker-hub-username.arn},
        ${aws_ssm_parameter.docker-hub-password.arn}
      ]
    }
  ]
}
POLICY
}

data "template_file" "buildspec" {
  template = "${file("buildspec.yml")}"
  vars = {
    env = var.env
  }
}

resource "aws_codebuild_project" "deploy_apps" {
  name          = "deploy_apps"
  description   = "test_wolkstack-build"
  build_timeout = "15"
  service_role  = aws_iam_role.deploy_apps.arn

  tags = {
    Environment = var.env
  }

  artifacts {
    encryption_disabled    = false
    name                   = "wolkstack-build-${var.env}"
    override_artifact_name = false
    packaging              = "NONE"
    type                   = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:4.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }

    s3_logs {
      encryption_disabled = false
      status              = "DISABLED"
    }
  }

  source {
    buildspec       = data.template_file.buildspec.rendered
    git_clone_depth = 0
    insecure_ssl    = false
    type            = "CODEPIPELINE"
  }
}
