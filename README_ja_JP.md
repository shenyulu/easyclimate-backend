<img src="https://github.com/shenyulu/easyclimate-backend/blob/main/docs/source/_static/logo1.svg?raw=true" alt="easyclimate-backend">

<h2 align="center">easyclimateのバックエンド</h2>

<p align="center">
<a href="https://easyclimate-backend.readthedocs.io/en/latest/"><strong>ドキュメント</strong> (最新版)</a> •
<a href="https://easyclimate-backend.readthedocs.io/en/main/"><strong>ドキュメント</strong> (mainブランチ)</a> •
<a href="https://shenyulu.github.io/easyclimate-backend/"><strong>ドキュメント</strong> (開発版)</a> •
<a href="https://shenyulu.github.io/easyclimate-backend/src/contributing.html"><strong>コントリビューション</strong></a>
</p>


![PyPI - バージョン](https://img.shields.io/pypi/v/easyclimate-backend)
![PyPI - Pythonバージョン](https://img.shields.io/pypi/pyversions/easyclimate-backend)
![PyPI - ダウンロード数](https://img.shields.io/pypi/dm/easyclimate-backend)
[![ドキュメント状態](https://readthedocs.org/projects/easyclimate-backend/badge/?version=latest)](https://easyclimate-backend.readthedocs.io/en/latest/?badge=latest)

<div align="center">
<center><a href = "README.md">English</a> / <a href = "README_zh_CN.md">简体中文</a> / 日本語</center>
</div>

Easyclimate-backendはEasyclimateフロントエンドパッケージの中核を担い、気象データ解析のための高性能な低レベル関数群を提供します。``Fortran``や``C``言語で実装されたこれらの関数は、気象データ処理の効率性と正確性を保証します。

## easyclimate-backendとは？

easyclimate-backendはEasyclimateの基盤処理を担当し、フロントエンドパッケージがユーザーフレンドリーな気象解析インターフェースを提供できるように設計されています。``Fortran``と``C``言語の速度と効率性を活用することで、最も計算量の多いタスクでもシームレスに処理します。

>   🚨 **本パッケージは急速な開発進行中** 🚨
>
>   全てのAPI（関数/クラス/インターフェース）は変更される可能性があります。設計思想の更新や新機能追加に伴い、後方互換性のない変更が発生する場合があります。完成版ではないため、利用には注意が必要です。

## インストール方法

Pythonパッケージ管理ツール[pip](https://pip.pypa.io/en/stable/getting-started/)を使用してインストール可能です：

```
pip install easyclimate-backend
```

## 動作要件

- Python >= 3.10
- Numpy = 2.1.0（ビルド時のみ必須。ビルド済みwheelはNumPy 1.24.3以降（2.x系含む）に対応）
- intel-fortran-rt
- dpcpp-cpp-rt

## オープンソースソフトウェア声明

[説明文書](https://easyclimate-backend.readthedocs.io/en/latest/src/softlist.html)を参照してください。