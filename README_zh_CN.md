<img src="https://github.com/shenyulu/easyclimate-backend/blob/main/docs/source/_static/logo1.svg?raw=true" alt="easyclimate-backend">

<h2 align="center">easyclimate 后端</h2>

<p align="center">
<a href="https://easyclimate-backend.readthedocs.io/en/latest/"><strong>文档</strong> (最新版)</a> •
<a href="https://easyclimate-backend.readthedocs.io/en/main/"><strong>文档</strong> (main分支)</a> •
<a href="https://shenyulu.github.io/easyclimate-backend/"><strong>文档</strong> (开发版)</a> •
<a href="https://shenyulu.github.io/easyclimate-backend/src/contributing.html"><strong>贡献指南</strong></a>
</p>


![PyPI - 版本](https://img.shields.io/pypi/v/easyclimate-backend)
![PyPI - Python版本](https://img.shields.io/pypi/pyversions/easyclimate-backend)
![PyPI - 下载量](https://img.shields.io/pypi/dm/easyclimate-backend)
[![文档状态](https://readthedocs.org/projects/easyclimate-backend/badge/?version=latest)](https://easyclimate-backend.readthedocs.io/en/latest/?badge=latest)

<div align="center">
<center><a href = "README.md">English</a> / 简体中文 / <a href = "README_ja_JP.md">日本語</a></center>
</div>

## 🤗 什么是 easyclimate-backend?

easyclimate-backend 专为 [easyclimate](https://github.com/shenyulu/easyclimate) 承担核心运算任务而设计，使前端包能够为用户提供友好的气候分析界面。通过发挥 ``Fortran`` 和 ``C`` 语言的速度与效率优势，确保即使是最复杂的计算任务也能无缝处理。

>   🚨 **本软件包仍在快速开发阶段** 🚨
>
>   所有API（函数/类/接口）均可能变更。随着设计理念的更新和新功能的加入，可能会出现非向后兼容的改动。当前版本尚未完成，请谨慎使用。

## 😯 如何安装?

可通过 Python 包管理工具 [pip](https://pip.pypa.io/en/stable/getting-started/) 安装：

```
pip install easyclimate-backend
```

## ✨ 依赖要求

- python >= 3.10
- Numpy = 2.1.0（仅构建时依赖，编译后的wheel支持NumPy 1.24.3及以上版本，含2.x系列）
- intel-fortran-rt
- dpcpp-cpp-rt

## 🪐 开源软件声明

请参阅[说明文档](https://easyclimate-backend.readthedocs.io/en/latest/src/softlist.html)。
