resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "deploy-apps-codepipeline"
  acl    = "private"
}

resource "aws_codepipeline" "deploy_apps" {
  name     = "tf-test-pipeline"
  role_arn = aws_iam_role.deploy_apps_codepipeline.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      run_order        = 1
      version          = "1"
      input_artifacts  = []
      output_artifacts = ["source_artifacts"]

      configuration = {
        "Owner"                = var.repository_owner
        "Repo"                 = var.repository_name
        "Branch"               = var.repository_branch
        "OAuthToken"           = var.github_token
        "PollForSourceChanges" = "false"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name            = "Build"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["source_artifacts"]
      run_order       = 2
      version         = "1"

      configuration = {
        "ProjectName" = "deploy_apps",
        "EnvironmentVariables" = jsonencode(
          [
            {
              name  = "environment"
              type  = "PLAINTEXT"
              value = var.env
            }
          ]
        )
      }
    }
  }
}

resource "aws_iam_role" "deploy_apps_codepipeline" {
  name = "test-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "codepipeline_policy"
  role = aws_iam_role.deploy_apps_codepipeline.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect":"Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketVersioning",
        "s3:PutObject"
      ],
      "Resource": [
        "${aws_s3_bucket.codepipeline_bucket.arn}",
        "${aws_s3_bucket.codepipeline_bucket.arn}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:BatchGetBuilds",
        "codebuild:StartBuild"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

# A shared secret between GitHub and AWS that allows AWS
# CodePipeline to authenticate the request came from GitHub.
# Would probably be better to pull this from the environment
# or something like SSM Parameter Store.
resource "random_string" "github_secret" {
  length  = 99
  special = false
}

resource "aws_codepipeline_webhook" "deploy_apps" {
  name            = "webhook-github-deploy-apps"
  authentication  = "GITHUB_HMAC"
  target_action   = "Source"
  target_pipeline = aws_codepipeline.deploy_apps.name

  authentication_configuration {
    secret_token = random_string.github_secret.result
  }

  filter {
    json_path    = "$.ref"
    match_equals = "refs/heads/{Branch}"
  }

  tags = {}
}

# Wire the CodePipeline webhook into a GitHub repository.
resource "github_repository_webhook" "deploy_apps" {
  repository = var.repository_name
  events     = ["push"]

  configuration {
    url          = aws_codepipeline_webhook.deploy_apps.url
    content_type = "json"
    insecure_ssl = true
    secret       = random_string.github_secret.result
  }
}
