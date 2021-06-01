terraform {
  backend "s3" {
    bucket         = "us-west-2-state" # mybucket name
    encrypt        = true
    key            = "terraform/terraform.tfstate" # path/to/my/key
    region         = "us-west-2"
    dynamodb_table = "us-west-2-locks"
    }
}