#!/bin/bash

YOCTO_SRC_DIR=/home/student/yocto
mkdir -p "$YOCTO_SRC_DIR"
chown student:student "$YOCTO_SRC_DIR"
rsync -avh --chown=student:student "$SRC/src/" "$YOCTO_SRC_DIR/" 

