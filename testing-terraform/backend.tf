terraform {
  backend "gcs" {
    bucket = "pro-terraform"
    prefix = "terraform/state"
  }
}