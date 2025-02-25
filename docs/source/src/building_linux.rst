.. _building-linux-wheels:

Building on Linux
===================

Dependencies
------------

- **Python** >= 3.10  
- **NumPy** == 2.1.0 (Required only for building the wheel; the built wheel is compatible with NumPy 1.24.3 and above, including 2.x versions)
- **intel-fortran-rt**  
- **dpcpp-cpp-rt**

Step-by-Step Instructions
-------------------------

1. Install Intel® HPC Toolkit
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Download and install the `Intel® HPC Toolkit <https://www.intel.com/content/www/us/en/developer/tools/oneapi/hpc-toolkit-download.html>`__ from the official website.

(1) Install with the GUI Installer
**********************************

1. From the console, locate the downloaded install file.
2. To launch the GUI installer:

- As root:

.. code-block:: bash

    sudo sh ./intel-oneapi-hpc-toolkit-2025.0.1.47_offline.sh

- As the current user:

.. code-block:: bash

    sh ./intel-oneapi-hpc-toolkit-2025.0.1.47_offline.sh

3. Follow the instructions in the installer.

(2) Command-Line Installation Instructions
******************************************

Read the documentation for `Command Line Installation Parameters <https://www.intel.com/content/www/us/en/developer/articles/technical/oneapi-command-line-installation.html>`__,
and decide which parameters to use. For example:

.. code-block:: bash

   sudo sh ./intel-oneapi-hpc-toolkit-2025.0.1.47_offline.sh -a --silent --cli --eula accept

This indicates a silent install (``--silent``) using a command-line interface (``--cli``) and accepting the End User License Agreement (``--eula accept``).  

.. note::

    You must accept the End User License Agreement by adding ``--eula accept`` to the command.

3. Download and run the installer:

Download the install script:

.. code-block:: bash

    wget https://registrationcenter-download.intel.com/akdlm/IRC_NAS/b7f71cf2-8157-4393-abae-8cea815509f7/intel-oneapi-hpc-toolkit-2025.0.1.47_offline.sh

Run the install script:  

.. code-block:: bash
    
    sudo sh ./intel-oneapi-hpc-toolkit-2025.0.1.47_offline.sh -a --silent --cli --eula accept

2. Configure the System After Installation
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

1. Open a terminal session.
2. Install CMake, pkg-config, and GNU development tools:

- **Ubuntu**:  
    ``sudo apt update``  
    ``sudo apt -y install cmake pkg-config build-essential``  
- **Red Hat and Fedora**:  
    ``sudo yum update``  
    ``sudo yum -y install cmake pkgconfig``  
    ``sudo yum groupinstall "Development Tools"``  
- **SUSE**:  
    ``sudo zypper update``  
    ``sudo zypper --non-interactive install cmake pkg-config``  
    ``sudo zypper --non-interactive install pattern devel_C_C++``

3. Verify the installation: 

.. code-block:: bash

    which cmake pkg-config make gcc g++

You should see one or more of these locations: 

.. code-block:: bash

    /usr/bin/cmake /usr/bin/pkg-config /usr/bin/make /usr/bin/gcc /usr/bin/g++

3. Activate Intel oneAPI Environment
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

After installation, activate the Intel oneAPI environment:

.. code-block:: bash

    source /opt/intel/oneapi/setvars.sh

4. Activate Python Environment
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Activate your `Anaconda <https://www.anaconda.com/download/success>`__ environment or a Python virtual environment (refer to `venv <https://docs.python.org/3/library/venv.html>`__):  
``conda activate myenv``  

.. note::  
   Replace ``myenv`` with the name of your actual environment.

5. Build the Wheel Package
~~~~~~~~~~~~~~~~~~~~~~~~~~

Execute the following script to build the wheel package:

.. code-block:: bash

    ./build_wheel_linux.sh

The contents of ``build_wheel_linux.sh`` are as follows:  

.. code-block:: bash  

   export CC=gcc  
   export FC=ifx  
   find . -type d -name "__pycache__" -exec rm -rf {} +  
   # https://github.com/mesonbuild/meson-python/issues/507  
   python -m build --wheel --no-isolation  

Additional Notes
----------------

- **Environment Setup**: Ensure the Intel® HPC Toolkit is properly installed and that the compiler environment is correctly configured via the Intel oneAPI command prompt.  
- **NumPy Compatibility**: While NumPy 2.1.0 is used during the wheel build process, the resulting wheel is compatible with NumPy 1.24.3 and higher, including 2.x versions.  
- **Troubleshooting**: The ``build_wheel_linux.sh`` script includes a workaround for a known ``meson-python`` issue; see the linked GitHub reference in the script comments for details.