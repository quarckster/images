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

variable "os" {
    type = string
}

variable "project_id" {
    type = string
    description = "Google Cloud project_id"
}


variable "zone" {
    type = string
    description = "Google Cloud zone"
}

variable "account_file" {
    type = string
    description = "Service account file to access Google Cloud API"
}

local "linux" {
  expression = {
    source_image = "ubuntu-2204-jammy-v20230919"
    result_image = "ubuntu-latest"
    runner_labels = "ubuntu-latest,ubuntu-22.04,linux-x86_64"
    runner_tarball_url = "https://github.com/actions/runner/releases/download/v2.309.0/actions-runner-linux-x64-2.309.0.tar.gz"
    runner_playbook = "${path.root}/linux/set-up-runner.yml"
  }
}

local "freebsd" {
  expression = {
    source_image = "freebsd-13-2-release-amd64"
    result_image = "freebsd-latest"
    runner_labels = "freebsd-latest,freebsd-13.2,freebsd-x86_64"
    runner_tarball_url = "https://github.com/ChristopherHX/github-act-runner/releases/download/v0.6.5/binary-freebsd-amd64.tar.gz"
    runner_playbook = "${path.root}/freebsd/set-up-runner.yml"
  }
}


locals {
  source_image = lookup(local, var.os, "").source_image
  result_image = lookup(local, var.os, "").result_image
  runner_labels = lookup(local, var.os, "").runner_labels
  runner_tarball_url = lookup(local, var.os, "").runner_tarball_url
  runner_playbook = lookup(local, var.os, "").runner_playbook
}

source "googlecompute" "runner" {
  account_file = var.account_file
  project_id = var.project_id
  zone = var.zone
  source_image = local.source_image
  image_name = local.result_image
  disk_size = 22
  use_os_login = true
  ssh_username = "packer"
}

build {
  sources = ["sources.googlecompute.runner"]
  provisioner "ansible" {
      playbook_file = local.runner_playbook
      extra_arguments = [ 
            "-e", 
            "runner_labels=${local.runner_labels}",
            "-e",
            "runner_tarball_url=${local.runner_tarball_url}"
        ]
    }
}
