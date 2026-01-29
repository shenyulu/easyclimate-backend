#!/bin/bash

# Set default MANYLINUX_VERSION if not provided
MANYLINUX_VERSION=${1:-manylinux_2_34_x86_64}

# Build an Image
# ------------------------------------------------
docker build --build-arg MANYLINUX_VERSION=${MANYLINUX_VERSION} -t my-image:${MANYLINUX_VERSION} .

# Run container
docker run -d --name my_container_${MANYLINUX_VERSION} my-image:${MANYLINUX_VERSION} tail -f /dev/null

# Build env
# ------------------------------------------------
repository_path=/root/easyclimate-backend
repository_python_build_requirement=/root/easyclimate-backend/scripts/build_requirement_manylinux.txt
repository_python314_build_requirement=/root/easyclimate-backend/scripts/build_requirement_3_14_manylinux.txt

# Copy repo
docker cp . my_container_${MANYLINUX_VERSION}:${repository_path}
# PyPI mirror
# docker exec my_container_${MANYLINUX_VERSION} /root/venv_py313/bin/python -m pip config set global.index-url https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple

# Install Packages for Python Environment
docker exec my_container_${MANYLINUX_VERSION} /root/venv_py313/bin/python -m pip install -r ${repository_python_build_requirement}
docker exec my_container_${MANYLINUX_VERSION} bash -c "source /root/venv_py313/bin/activate && cd ${repository_path} && source /opt/intel/oneapi/setvars.sh --force && git config --global safe.directory '*' && bash ./scripts/topbuild_manysdist_linux.sh && cd /root"

# Copy file from the container to the host
# ------------------------------------------------
# docker cp my_container_${MANYLINUX_VERSION}:${repository_path}/wheelhouse ./wheelhouse_${MANYLINUX_VERSION}
docker cp my_container_${MANYLINUX_VERSION}:${repository_path}/dist ./wheelhouse_${MANYLINUX_VERSION}

# Delete the container and image
# ------------------------------------------------
docker rm -f my_container_${MANYLINUX_VERSION}
# docker rmi my-image:${MANYLINUX_VERSION}
mkdir -p ./dist
cp ./wheelhouse_${MANYLINUX_VERSION}/*.tar.gz ./dist
rm -r ./wheelhouse_${MANYLINUX_VERSION}