variable "DEFAULT_TAG" {
  default = "msmtpd:test"
}

# GitHub Bake Action
target "docker-metadata-action" {
  tags = [ "${DEFAULT_TAG}" ]
}

group "default" {
  targets = [ "test" ]
}

target "image" {
  inherits = [ "docker-metadata-action" ]
}

target "test" {
  inherits = [ "image" ]
  output = ["type=docker"]
}

target "all" {
  inherits = [ "image" ]
  platforms = [
    "linux/amd64"
  ]
}