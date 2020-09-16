resource "aws_ssm_parameter" "docker-hub-username" {
  name        = "/docker-hub-username"
  description = "The parameter description"
  type        = "SecureString"
  value       = var.docker_hub_username

  tags = {
    environment = "production"
  }
}

resource "aws_ssm_parameter" "docker-hub-password" {
  name        = "/docker-hub-password"
  description = "The parameter description"
  type        = "SecureString"
  value       = var.docker_hub_password

  tags = {
    environment = "production"
  }
}
