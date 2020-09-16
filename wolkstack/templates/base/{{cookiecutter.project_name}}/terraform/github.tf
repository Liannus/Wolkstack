
# Configure the GitHub Provider
provider "github" {
  token = var.github_token
  owner = var.repository_owner
}
