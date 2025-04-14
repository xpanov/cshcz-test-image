#!/bin/sh -x

DEBIAN_FRONTEND=noninteractive sudo apt-get update

# install pip

DEBIAN_FRONTEND=noninteractive sudo apt-get install -y python3-pip