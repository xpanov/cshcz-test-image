#!/bin/sh -x

# install ansible
DEBIAN_FRONTEND=noninteractive sudo apt-add-repository -y ppa:ansible/ansible
DEBIAN_FRONTEND=noninteractive sudo apt update
DEBIAN_FRONTEND=noninteractive sudo apt -y install ansible