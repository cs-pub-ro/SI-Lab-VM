#!/bin/bash

# give student user permissions to serial devices
usermod -a -G dialout student

# install python tools for student user
su -c "pipx ensurepath" - student || true
su -c "pipx install esptool" - student
su -c "pipx install pyserial" - student

