<img src="https://github.com/shenyulu/easyclimate-backend/blob/main/docs/source/_static/logo1.svg?raw=true" alt="easyclimate-backend">

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
<center>English / <a href = "README_zh_CN.md">简体中文</a> / <a href = "README_ja_JP.md">日本語</a></center>
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

## 🪐 Open Source Software Statement

Please refer to the [document](https://easyclimate-backend.readthedocs.io/en/latest/src/softlist.html).
