#!/bin/bash

growpart /dev/vda 2 || true
resize2fs /dev/vda2 || true

