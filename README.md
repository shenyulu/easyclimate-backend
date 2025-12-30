<img src="https://github.com/shenyulu/easyclimate-backend/blob/main/docs/source/_static/easyclimate_backend_logo_mini.png?raw=true" alt="easyclimate-backend">

<h2 align="center">The backend of easyclimate</h2>

<p align="center">
<a href="https://easyclimate-backend.readthedocs.io/en/latest/"><strong>Documentation</strong> (latest)</a> •
<a href="https://easyclimate-backend.readthedocs.io/en/main/"><strong>Documentation</strong> (main branch)</a> •
<a href="https://shenyulu.github.io/easyclimate-backend/"><strong>Documentation</strong> (Dev)</a> •
<a href="https://shenyulu.github.io/easyclimate-backend/src/contributing.html"><strong>Contributing</strong></a>
</p>


![PyPI - Version](https://img.shields.io/pypi/v/easyclimate-backend)
![PyPI - Python Version](https://img.shields.io/pypi/pyversions/easyclimate-backend)
![PyPI - Downloads](https://img.shields.io/pypi/dm/easyclimate-backend)
[![Documentation Status](https://readthedocs.org/projects/easyclimate-backend/badge/?version=latest)](https://easyclimate-backend.readthedocs.io/en/latest/?badge=latest)

<div align="center">
<center>English / <a href = "readme/README_zh_CN.md">简体中文</a> / <a href = "readme/README_ja_JP.md">日本語</a></center>
</div>


## 🤗 What is easyclimate-backend?

The easyclimate-backend is designed to handle the heavy lifting for [easyclimate](https://github.com/shenyulu/easyclimate), 
allowing the front-end package to offer a user-friendly interface for climate analysis. By leveraging the speed and efficiency of ``Fortran`` and ``C``, 
The easyclimate-backend makes sure that even the most computationally intensive tasks are managed seamlessly.



>   🚨 **This package is still undergoing rapid development.** 🚨
>
>   All of the API (functions/classes/interfaces) is subject to change. 
>   There may be non-backward compatible changes as we experiment with new design ideas and implement new features. 
>   This is not a finished product, use with caution.

## 😯 How to install?

The `easyclimate-backend` package can be installed using Python package installer [pip](https://pip.pypa.io/en/stable/getting-started/).

```
pip install easyclimate-backend
```

## ✨ Requires

- python >= 3.10
- Numpy = 2.1.0 (Required only for building the wheel; the built wheel is compatible with NumPy 1.24.3 and above, including 2.x versions)
- intel-fortran-rt
- dpcpp-cpp-rt

## 🔧 Build Instructions

### Prerequisites (General)

- Windows: Windows 10+
- Linux: glibc 2.28 or later, including: Debian 10+, Ubuntu 18.10+, Fedora 29+, CentOS/RHEL 8+.

### Windows

1. Install Intel® oneAPI HPC Toolkit
   👉 [Get the Intel® oneAPI HPC Toolkit](https://www.intel.com/content/www/us/en/developer/tools/oneapi/hpc-toolkit-download.html)
2. Install `uv`:

```powershell
winget install uv
```

3. Install Powershell 7
   👉 [Install PowerShell on Windows](https://learn.microsoft.com/en-us/powershell/scripting/install/install-powershell-on-windows?view=powershell-7.5)

4. Activate Intel oneAPI environment and run the build script from the project root:

Open the Intel oneAPI command prompt for Intel 64 for Visual Studio 2022 (or higher versions) from the Start menu.

<img src="https://github.com/shenyulu/easyclimate-backend/blob/main/docs/source/_static/fig1.png?raw=true" alt="easyclimate-backend">

At this point, a cmd terminal window will open and the following information will be printed.

```
:: initializing oneAPI environment...
   Initializing Visual Studio command-line environment...
   Visual Studio version 17.14.23 environment configured.
   "C:\Program Files\Microsoft Visual Studio\2022\Community\"
   Visual Studio command-line environment initialized for: 'x64'
:  advisor -- latest
:  compiler -- latest
:  dal -- latest
:  debugger -- latest
:  dev-utilities -- latest
:  dnnl -- latest
:  dpcpp-ct -- latest
:  dpl -- latest
:  ipp -- latest
:  ippcp -- latest
:  mkl -- latest
:  mpi -- latest
:  ocloc -- latest
:  pti -- latest
:  tbb -- latest
:  umf -- latest
:  vtune -- latest
:: oneAPI environment initialized ::
```

Type "pwsh" in your terminal, and then run command

```powershell
pwsh
cd D:\easyclimate-backend # Replace with your project path
.\scripts\build_wheel_windows.ps1
```

4. The generated wheel file will be located in the `dist/` directory.

### Linux

1. Install Docker on your system.
2. Run the build script on a Linux host in project root:

```bash
cd /home/shenyulu/easyclimate-backend
./scripts/topbuild_manywheel_linux.sh
```

The resulting wheel will also be placed in the `dist/` directory.


## 🪐 Open Source Software Statement

Please refer to the [document](https://easyclimate-backend.readthedocs.io/en/latest/src/softlist.html).
