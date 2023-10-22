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
    validation {
      condition = contains(["ubuntu", "ubuntu-arm64", "freebsd", "windows"], var.os)
      error_message = "Not supported OS."
  }
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

local "ubuntu" {
  expression = {
    source_image = "ubuntu-2204-jammy-v20230919"
    runner_labels = "ubuntu-latest,ubuntu-22.04,linux-x86_64"
    runner_tarball_url = "https://github.com/actions/runner/releases/download/v2.310.2/actions-runner-linux-x64-2.310.2.tar.gz"
    disk_size = 20
    communicator = "ssh"
    use_proxy = true
    start_script = "${abspath(path.root)}/start-runner.sh"
    metadata = {}
    arch = "x86-64"
    machine_type = "e2-standard-2"
  }
}

local "ubuntu-arm64" {
  expression = {
    source_image = "ubuntu-2204-jammy-arm64-v20230919"
    runner_labels = "ubuntu-arm64-latest,ubuntu-arm64-22.04,linux-arm64"
    runner_tarball_url = "https://github.com/actions/runner/releases/download/v2.310.2/actions-runner-linux-arm64-2.310.2.tar.gz"
    disk_size = 20
    communicator = "ssh"
    use_proxy = true
    start_script = "${abspath(path.root)}/start-runner.sh"
    metadata = {}
    arch = "arm64"
    machine_type = "t2a-standard-2"
  }
}

local "freebsd" {
  expression = {
    source_image = "freebsd-13-2-release-amd64"
    runner_labels = "freebsd-latest,freebsd-13.2,freebsd-x86_64"
    runner_tarball_url = "https://github.com/ChristopherHX/github-act-runner/releases/download/v0.6.5/binary-freebsd-amd64.tar.gz"
    disk_size = 22
    communicator = "ssh"
    use_proxy = true
    start_script = "${abspath(path.root)}/start-runner.sh"
    metadata = {}
    arch = "x86-64"
    machine_type = "e2-standard-2"
  }
}

local "windows" {
  expression = {
    source_image = "windows-server-2022-dc-core-v20231011"
    runner_labels = "windows-latest,windows-server-2022,windows-x86_64"
    runner_tarball_url = "https://github.com/actions/runner/releases/download/v2.310.2/actions-runner-win-x64-2.310.2.zip"
    disk_size = 50
    communicator = "winrm"
    use_proxy = false
    start_script = "${abspath(path.root)}/start-runner.ps1"
    metadata = {
      "sysprep-specialize-script-ps1" = "Set-Item -Path WSMan:\\localhost\\Service\\Auth\\Basic -Value $true"
    }
    arch = "x86-64"
    machine_type = "e2-standard-2"
  }
}

locals {
  source_image = lookup(local, var.os, "").source_image
  runner_labels = lookup(local, var.os, "").runner_labels
  runner_tarball_url = lookup(local, var.os, "").runner_tarball_url
  disk_size = lookup(local, var.os, "").disk_size
  metadata = lookup(local, var.os, "").metadata
  communicator = lookup(local, var.os, "").communicator
  use_proxy = lookup(local, var.os, "").use_proxy
  start_script = lookup(local, var.os, "").start_script
  arch = lookup(local, var.os, "").arch
  os = split("-", var.os)[0]
  machine_type = lookup(local, var.os, "").machine_type
}

local "datetime" {
  expression = formatdate("YYYYMMDD-hhmm", timestamp())
}

source "googlecompute" "runner" {
  account_file = var.account_file
  project_id = var.project_id
  zone = var.zone
  source_image = local.source_image
  image_name = "${local.os}-${local.arch}-${local.datetime}"
  disk_size = local.disk_size
  communicator = local.communicator
  use_os_login = true
  winrm_username = "packer"
  ssh_username = "packer"
  winrm_use_ssl = true
  winrm_insecure = true
  metadata = local.metadata
  machine_type = local.machine_type
}

build {
  sources = ["sources.googlecompute.runner"]
  provisioner "ansible" {
      playbook_file = "${abspath(path.root)}/../../os/${local.os}/setup-runner.yml"
      use_proxy = local.use_proxy
      extra_arguments = [ 
            "-e", 
            "runner_labels=${local.runner_labels}",
            "-e",
            "runner_tarball_url=${local.runner_tarball_url}",
            "-e",
            "start_script=${local.start_script}"
        ]
    }
}
