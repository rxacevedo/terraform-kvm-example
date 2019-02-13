data "terraform_remote_state" "volumes" {
  backend = "local"

  config {
    path = "${path.module}/../volumes/terraform.tfstate"
  }
}
