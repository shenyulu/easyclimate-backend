.. _building-manylinux-wheels:

Building manylinux wheels in Docker
===================================

Overview
--------
This document provides instructions for building Python manylinux wheels using Docker. Manylinux wheels are portable Python binary distributions compatible with multiple Linux distributions, adhering to the manylinux standards (e.g., manylinux_2_34). The process leverages a Docker container based on the ``quay.io/pypa/manylinux_2_34_x86_64`` image to ensure a consistent build environment across different Python versions (3.10, 3.11, 3.12, and 3.13).

Prerequisites
-------------
Before proceeding, ensure the following requirements are met:

- **Docker**: Installed and running on your system. Verify with ``docker --version``.
- **Project Files**: The following files must be present in your working directory:

  - ``build_docker_manylinux.sh``: The shell script to orchestrate the Docker build and wheel extraction.
  - ``Dockerfile``: The configuration file defining the Docker image.
  - ``build_requirement_manylinux.txt``: A text file listing Python package dependencies.
  - ``build_wheel_manylinux.sh``: A script inside the repository to build the wheels (exist in the project).
  - A project repository directory (i.e., ``easyclimate-backend``) copied into the container.

- **Permissions**: Ensure you have sufficient permissions to run Docker commands (e.g., add your user to the ``docker`` group or use ``sudo``).
- **Disk Space**: Allocate enough space for the Docker image and wheel files (minimum 5-10 GB recommended).

Step-by-Step Instructions
-------------------------

1. Prepare the Environment
~~~~~~~~~~~~~~~~~~~~~~~~~~
Clone or place your project repository in the current working directory. Ensure all required files are present and executable:

.. code-block:: bash

   chmod +x build_docker_manylinux.sh

2. Execute the Build Script
~~~~~~~~~~~~~~~~~~~~~~~~~~~
Run the following command to initiate the entire process:

.. code-block:: bash

   bash build_docker_manylinux.sh

This script performs the following actions:

- Builds a Docker image named ``my-image``.
- Runs a container named ``my-container`` from the image.
- Copies the built wheel files from the container to the host.
- Cleans up by removing the container and image.

3. Verify Outputs
~~~~~~~~~~~~~~~~~
After execution, check the ``./dist`` directory for the generated wheel files (``.whl``). These files are compatible with manylinux_2_34 and the specified Python versions.

File Details
------------

``build_docker_manylinux.sh``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
This shell script automates the Docker workflow:

.. code-block:: bash

   #!/bin/bash

   # Build an Image
   # ------------------------------------------------
   echo "Building Docker image..."
   docker build -t my-image .

   # Run container
   echo "Running Docker container..."
   docker run --name my-container my-image

   # Copy file from the container to the host
   # ------------------------------------------------
   echo "Copying wheel files to host..."
   mkdir -p ./wheelhouse
   docker cp my-container:/root/easyclimate-backend/wheelhouse ./wheelhouse
   # Uncomment the following line if additional artifacts are needed from /dist
   # docker cp my-container:/root/easyclimate-backend/dist ./dist

   # Delete the container and image
   # ------------------------------------------------
   echo "Cleaning up container and image..."
   docker rm my-container
   docker rmi my-image

   # Organize output
   echo "Organizing wheel files..."
   mkdir -p ./dist
   cp ./wheelhouse/*.whl ./dist
   rm -r ./wheelhouse

   echo "Build process completed successfully."

``Dockerfile``
~~~~~~~~~~~~~~
This file defines the Docker image configuration:

.. code-block:: dockerfile

   # Base image for manylinux_2_34 compatibility
   FROM quay.io/pypa/manylinux_2_34_x86_64

   # Metadata
   LABEL version="2025.3.0" maintainer="shenyulu"

   # Define build arguments
   ARG repository_path=/root/easyclimate-backend
   ARG repository_python_build_requirement=/root/easyclimate-backend/build_requirement_manylinux.txt

   # Set working directory
   WORKDIR /root

   # Configure AlmaLinux mirror for faster package downloads
   RUN sed -e 's|^mirrorlist=|#mirrorlist=|g' \
       -e 's|^# baseurl=https://repo.almalinux.org|baseurl=https://mirrors.aliyun.com|g' \
       -i.bak /etc/yum.repos.d/almalinux*.repo

   # Install AlmaLinux packages
   COPY /config /etc/yum.repos.d
   RUN yum install -y wget
   RUN yum install -y intel-oneapi-hpc-toolkit
   RUN yum clean all

   # Set up Python virtual environments for multiple versions
   RUN /opt/python/cp313-cp313/bin/python -m venv venv_py313
   RUN /opt/python/cp312-cp312/bin/python -m venv venv_py312
   RUN /opt/python/cp311-cp311/bin/python -m venv venv_py311
   RUN /opt/python/cp310-cp310/bin/python -m venv venv_py310

   # Copy project repository into the container
   COPY . ${repository_path}

   # Configure PyPI mirror for faster package downloads
   RUN /root/venv_py313/bin/python -m pip config set global.index-url https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple

   # Install dependencies and build wheels for each Python version
   RUN /root/venv_py313/bin/python -m pip install -r ${repository_python_build_requirement}
   RUN source /root/venv_py313/bin/activate && \
       cd ${repository_path} && \
       source /opt/intel/oneapi/setvars.sh --force && \
       bash ./build_wheel_manylinux.sh && \
       cd /root

   RUN /root/venv_py312/bin/python -m pip install -r ${repository_python_build_requirement}
   RUN source /root/venv_py312/bin/activate && \
       cd ${repository_path} && \
       source /opt/intel/oneapi/setvars.sh --force && \
       bash ./build_wheel_manylinux.sh && \
       cd /root

   RUN /root/venv_py311/bin/python -m pip install -r ${repository_python_build_requirement}
   RUN source /root/venv_py311/bin/activate && \
       cd ${repository_path} && \
       source /opt/intel/oneapi/setvars.sh --force && \
       bash ./build_wheel_manylinux.sh && \
       cd /root

   RUN /root/venv_py310/bin/python -m pip install -r ${repository_python_build_requirement}
   RUN source /root/venv_py310/bin/activate && \
       cd ${repository_path} && \
       source /opt/intel/oneapi/setvars.sh --force && \
       bash ./build_wheel_manylinux.sh && \
       cd /root

Troubleshooting
---------------
- **Docker Build Fails**: Check for syntax errors in the ``Dockerfile`` or missing files in the working directory.
- **Permission Denied**: Ensure Docker commands are run with appropriate privileges.
- **No Wheels Generated**: Verify that ``build_wheel_manylinux.sh`` exists and executes correctly within the container.

Conclusion
----------
This setup provides a reproducible method to build manylinux wheels for Python projects. The resulting ``.whl`` files in the ``./dist`` directory can be distributed or uploaded to PyPI.