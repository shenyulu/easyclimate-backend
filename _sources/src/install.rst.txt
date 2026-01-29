.. _install:

Installation
============

Overview
--------
This document provides step-by-step instructions for installing the ``easyclimate-backend`` package, a lightweight and efficient tool designed for climate data processing. The installation process leverages the Python Package Index (PyPI) and the ``pip`` package manager to ensure you obtain the latest stable version of the software.

Prerequisites
-------------
Before proceeding with the installation, ensure the following requirements are met:

- **Python Version**: Python 3.6 or higher is installed on your system. Verify this by running:

  .. code-block:: bash

      python --version

  or

  .. code-block:: bash

      python3 --version

- **pip**: The Python package manager ``pip`` is installed and up-to-date. Check the version with:

  .. code-block:: bash

      pip --version

  If ``pip`` is outdated, update it using:

  .. code-block:: bash

      pip install --upgrade pip

- **Internet Connection**: Required to download the package from PyPI.
- **Permissions**: Ensure you have sufficient permissions to install packages in your Python environment. Use administrator or sudo privileges if necessary.

Installation Steps
------------------
Follow these steps to install ``easyclimate-backend`` using ``pip``:

1. **Open a Terminal or Command Prompt**  
   Launch your system’s terminal (e.g., Command Prompt on Windows, Terminal on macOS/Linux).

2. **Install the Package**  
   Run the following command to download and install the latest version of ``easyclimate-backend``:

   .. code-block:: bash

       pip install easyclimate-backend

   This command fetches the package and its dependencies from PyPI and installs them into your Python environment.

3. **Verify the Installation**  
   To confirm that ``easyclimate-backend`` was installed successfully, check the installed version by running:

   .. code-block:: bash

       pip show easyclimate-backend

   This will display metadata such as the package name, version, and installation location.

Troubleshooting
---------------
If you encounter issues during installation, consider the following:

- **Permission Denied**: If you see a permissions error, prepend ``sudo`` (on Linux/macOS) or run the terminal as an administrator (on Windows):

  .. code-block:: bash

      sudo pip install easyclimate-backend

- **Network Issues**: Ensure your internet connection is stable. If PyPI is unreachable, retry or use a mirror (consult ``pip`` documentation for details).
- **Virtual Environment**: If working in a virtual environment (recommended for isolated setups), activate it first:

  .. code-block:: bash

      source venv/bin/activate  # Linux/macOS
      venv\Scripts\activate     # Windows


Post-Installation
-----------------
Once installed, ``easyclimate-backend`` is ready to use. Import it in your Python scripts as follows:

.. code-block:: python

    import easyclimate_backend

Refer to the package’s official documentation for usage instructions, API references, and examples.

Support
-------
For further assistance, contact the package maintainers via the official repository (e.g., GitHub) or check the PyPI page for additional resources.
