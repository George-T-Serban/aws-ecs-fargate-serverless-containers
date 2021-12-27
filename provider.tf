provider "aws" {
  region = var.aws_region

  # Configure default tags for all resources deployed
  default_tags {
    tags = {
      Environment = "Demo"
      Service     = "wordpress"
    }
  }
}