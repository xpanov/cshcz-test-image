# Ubuntu 22.04 Base image

This repo contains Packer files for building Ubuntu 22.04 LTS Jammy Jellyfish amd64 base image for QEMU/OpenStack and for VirtualBox/Vagrant using Gitlab CI/CD.

## Image for QEMU/OpenStack

Built from [live server ISO](https://www.releases.ubuntu.com/jammy/) using [QEMU builder](https://developer.hashicorp.com/packer/plugins/builders/qemu).

There is one user account:

*  `ubuntu` created by [cloud-init](https://cloudinit.readthedocs.io/en/latest/), enabled for SSH

## Image for VirtualBox/Vagrant

Built from [official Vagrant box](https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64-vagrant.box) provided by an OS vendor using [Vagrant builder](https://developer.hashicorp.com/packer/plugins/builders/vagrant).

There is one user account:

*  `vagrant` with password `vagrant`, enabled for SSH

## How to build

For information how to build this image see [wiki](https://gitlab.ics.muni.cz/muni-kypo-images/muni-kypo-images-wiki/-/wikis/How-to-build-an-image-locally).

## Known issues and requested features

See [issues](https://gitlab.ics.muni.cz/muni-kypo-images/ubuntu-22.04/-/issues).

## License

This project is licensed under the [MIT License](LICENSE).