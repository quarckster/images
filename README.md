# Images

This repository stores recipies for building VM and container images. To build VM images Hashicorp
Packer is used.

## Build

Example command to build a self-hosted runner VM image in Google Cloud:

```sh
packer build -var project_id=<PROJECT ID> \
             -var zone=<ZONE> \
             -var account_file=<PATH TO ACCOUNT FILE> \
             google/linux/linux_runner.pkr.hcl
```
