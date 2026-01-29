.. _building-manylinux-wheels:

Building manylinux wheels in Docker
===================================

Overview
--------
This document provides instructions for building Python manylinux wheels using Docker. Manylinux wheels are portable 
Python binary distributions compatible with multiple Linux distributions, adhering to the manylinux standards (e.g., manylinux_2_34). 
The process leverages a Docker container based on the ``quay.io/pypa/manylinux_2_34_x86_64`` image 
to ensure a consistent build environment across different Python versions (3.10, 3.11, 3.12, 3.13, and 3.14).

Prerequisites
-------------
Before proceeding, ensure the following requirements are met:

- **Docker**: Installed and running on your system. Verify with ``docker --version``.
- **Project Files**: The following files must be present in your working directory:
- **Permissions**: Ensure you have sufficient permissions to run Docker commands (e.g., add your user to the ``docker`` group or use ``sudo``).
- **Disk Space**: Allocate enough space for the Docker image and wheel files (minimum 5-10 GB recommended).

Step-by-Step Instructions
-------------------------

1. Prepare the Environment
~~~~~~~~~~~~~~~~~~~~~~~~~~
Clone or place your project repository in the current working directory. Ensure all required files are present and executable:

.. code-block:: bash

   chmod +x ./scripts/topbuild_manywheel_linux.sh

2. Execute the Build Script
~~~~~~~~~~~~~~~~~~~~~~~~~~~
Run the following command to initiate the entire process:

.. code-block:: bash

   bash ./scripts/topbuild_manywheel_linux.sh

This script performs the following actions:

- Builds a Docker image named ``my-image``.
- Runs a container named ``my-container`` from the image.
- Copies the built wheel files from the container to the host.
- Cleans up by removing the container and image.

Conclusion
----------
This setup provides a reproducible method to build manylinux wheels for Python projects. The resulting ``.whl`` files in the ``./dist`` directory can be distributed or uploaded to PyPI.