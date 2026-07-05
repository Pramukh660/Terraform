locals {
  custom_data = base64encode(templatefile("${path.module}/cloud-init.yaml.tftpl", {
    github_username = var.github_username
    github_pat      = var.github_pat
    docker_image    = var.docker_image
    app_env         = var.app_env
  }))
}
