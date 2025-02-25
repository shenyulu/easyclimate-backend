.. _building-windows-wheels:

Building on Windows
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

2. Launch Intel oneAPI Command Prompt
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
After installation, open the ``Intel oneAPI command prompt for Intel 64 for Visual Studio 2022`` (or higher versions) from the Start menu.

.. figure:: ../_static/fig1.png
   :scale: 100%
   :align: center

   Opening the Command Prompt

3. Switch to PowerShell Mode
~~~~~~~~~~~~~~~~~~~~~~~~~~~~
In the opened command prompt window, switch to PowerShell mode by entering the following command:

.. code-block:: powershell

   $ powershell

4. Activate Python Environment
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Activate your `Anaconda <https://www.anaconda.com/download/success>`__ environment or a Python virtual environment (refer to `venv <https://docs.python.org/3/library/venv.html>`__):

.. code-block:: powershell

   $ conda activate myenv

.. note::

   Replace ``myenv`` with the name of your actual environment.

5. Install Required Dependencies
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Install the necessary dependencies listed in the ``build_requirement_windows.txt`` file (root path) by running:

.. code-block:: powershell

   $ pip install -r build_requirement_windows.txt

The contents of ``build_requirement_windows.txt`` are as follows:

::

   meson-python
   build
   ninja
   numpy==2.1.0

6. Build the Wheel Package
~~~~~~~~~~~~~~~~~~~~~~~~~~
Execute the following PowerShell script to build the wheel package:

.. code-block:: powershell

   $ .\build_wheel_windows.ps1

The contents of ``build_wheel_windows.ps1`` are as follows:

.. code-block:: powershell

   $Env:CC="cl"
   $Env:FC="ifx"
   Get-ChildItem -Path . -Recurse -Directory -Filter __pycache__ | Remove-Item -Recurse -Force

   # https://github.com/mesonbuild/meson-python/issues/507
   python -m build --wheel --no-isolation

.. rubric:: Explanation

- This script sets essential environment variables (e.g., ``CC`` and ``FC``) and removes ``__pycache__`` directories to ensure a clean build.  
- The ``--no-isolation`` flag prevents the use of an isolated build environment, speeding up the process.  
- The script addresses a known issue with ``meson-python``, as documented in `this GitHub issue <https://github.com/mesonbuild/meson-python/issues/507>`__.

Additional Notes
----------------

- **Environment Setup**: Ensure the Intel® HPC Toolkit is properly installed and that the compiler environment is correctly configured via the Intel oneAPI command prompt.  
- **NumPy Compatibility**: While NumPy 2.1.0 is used during the wheel build process, the resulting wheel is compatible with NumPy 1.24.3 and higher, including 2.x versions.  
- **Troubleshooting**: The ``build_wheel_windows.ps1`` script includes a workaround for a known ``meson-python`` issue; see the linked GitHub reference in the script comments for details.
