packer {
  required_plugins {
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = "~> 1"
    }
    googlecompute = {
      source  = "github.com/hashicorp/googlecompute"
      version = "~> 1"
    }
  }
}

variable "project_id" {
    type = string
    description = "Google Cloud project_id"
}

variable "source_image" {
    type = string
    default = "ubuntu-2204-jammy-v20230919"
    description = "Image where runner will be installed"
}

variable "zone" {
    type = string
    description = "Google Cloud zone"
}

variable "account_file" {
    type = string
    description = "Service account file to access Google Cloud API"
}

variable "image_name" {
    type = string
    description = "Resulting image name"
    default = "ubuntu-latest"
}

variable "runner_labels" {
    type = string
    default = "ubuntu-latest,ubuntu-22.04,linux-x86_64"
    description = "Label that will be assigned to the runner during registration"
}

variable "runner_tarball_url" {
    type = string
    default = "https://github.com/actions/runner/releases/download/v2.309.0/actions-runner-linux-x64-2.309.0.tar.gz"
}

source "googlecompute" "linux-runner" {
  project_id = var.project_id
  source_image = var.source_image
  zone = var.zone
  use_os_login = true
  ssh_username = "packer"
  account_file = var.account_file
  image_name = var.image_name
}

build {
  sources = ["sources.googlecompute.linux-runner"]
  provisioner "ansible" {
      playbook_file = "./linux-runner-playbook.yml"
      extra_arguments = [ 
            "-e", 
            "runner_labels=${var.runner_labels}",
            "-e",
            "runner_tarball_url=${var.runner_tarball_url}"
        ]
    }
}
