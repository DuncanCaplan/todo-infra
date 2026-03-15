terraform {
    backend "s3" {
        bucket = "todo-tfstate-060476966476"
        key = "dev/terraform.tfstate"
        region = "eu-west-2"
        use_lockfile = true
        encrypt = true
    }
}