#!/bin/bash

apt-get -y -qq update

# Yocto Linux Dependencies
apt-get -y install gawk wget git diffstat unzip texinfo gcc build-essential \
	chrpath socat cpio python3 python3-pip python3-pexpect xz-utils debianutils \
	iputils-ping python3-git python3-jinja2 libegl1-mesa libsdl1.2-dev \
	python3-pylint-common python3-subunit mesa-common-dev zstd liblz4-tool

# install kas
pip3 install kas

