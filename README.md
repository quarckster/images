# Images

This repository stores recipies for building VM and container images.

# Prerequisites

* [Packer>=1.9.4](https://www.packer.io)
* [Ansible>=2.15.4](https://www.ansible.com)
  * [ansible.windows>=2.1.0](https://galaxy.ansible.com/ui/repo/published/ansible/windows/)
  * [chocolatey.chocolatey>=1.5.1](https://galaxy.ansible.com/ui/repo/published/chocolatey/chocolatey)
  * [community.general>=7.5.0](https://galaxy.ansible.com/ui/repo/published/community/general)
  * [community.windows>=2.0.0](https://galaxy.ansible.com/ui/repo/published/community/windows)
  * [pywinrm>=0.3.0](https://pypi.org/project/pywinrm/)

## Build

Example command to build a self-hosted runner VM image in Google Cloud:

```sh
packer build -var project_id=<PROJECT ID> \
             -var zone=<ZONE> \
             -var account_file=<PATH TO ACCOUNT FILE> \
             -var os=ubuntu
             providers/google/runner.pkr.hcl
```
