#!/bin/bash

echo "[INFO] Process manylinux_2_28_x86_64"
echo "------------------------------------"
./scripts/build_docker_manylinux.sh manylinux_2_28_x86_64
echo "[INFO] END Process manylinux_2_28_x86_64"
echo "----------------------------------------"

echo "[INFO] Process manylinux_2_34_x86_64"
echo "------------------------------------"
./scripts/build_docker_manylinux.sh manylinux_2_34_x86_64
echo "[INFO] END Process manylinux_2_34_x86_64"
echo "----------------------------------------"