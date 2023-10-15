#!/bin/bash

# install python tools for student user
su -c "pipx ensurepath" - student || true
su -c "pipx install esptool" - student
su -c "pipx install pyserial" - student

