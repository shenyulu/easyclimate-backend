.. easyclimate-backend documentation master file, created by
   sphinx-quickstart on Fri Feb 21 21:48:45 2025.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Welcome to Easyclimate-backend's documentation! 🚀
======================================================

Easyclimate-backend is the powerhouse behind the Easyclimate front-end package, providing a suite of high-performance, 
low-level functions for climate data analysis. Implemented in languages like ``Fortran`` and ``C``, 
these functions ensure that your climate data processing is both efficient and accurate.

.. figure:: ./_static/logo1.svg
   :scale: 100%
   :align: center

What is Easyclimate-backend?
----------------------------

The easyclimate-backend is designed to handle the heavy lifting for Easyclimate, 
allowing the front-end package to offer a user-friendly interface for climate analysis. By leveraging the speed and efficiency of ``Fortran`` and ``C``, 
The easyclimate-backend makes sure that even the most computationally intensive tasks are managed seamlessly.

.. warning::

   🚨 This package is still undergoing rapid development. 🚨

   All of the API (functions/classes/interfaces) is subject to change. 
   There may be non-backward compatible changes as we experiment with new design ideas and implement new features. 
   This is not a finished product, use with caution.

Key Features
------------

- **Aerobulk** 🌊: For bulk aerodynamic calculations, essential for understanding air-sea interactions.
- **FFTpack** 📈: Fast Fourier Transform operations for frequency domain analysis of time series data.
- **Heat_Stress** 🌡️: Calculations related to heat stress indices, crucial for studying climate impacts on human health.
- **PySpharm** 🌍: Spherical harmonic functions for analyzing data on a sphere, perfect for global climate patterns.
- **Redfit** 📊: Tools for fitting red noise to time series data, useful in climate variability studies.
- **Windspharm** 💨: Functions for wind speed and direction calculations, vital for atmospheric dynamics.
- **WRF-Python** ⛈️: Utilities for working with output from the Weather Research and Forecasting (WRF) model.

Installation
------------

Installing the easyclimate-backend is straightforward. Since it's available on PyPI, you can install it using pip:

.. code-block:: bash

   pip install easyclimate-backend

No need for Conda; it's simple and direct.

Getting Started
---------------

To get started, check out our `Getting Started <getting_started.html>`_ guide. It will walk you through the basics of using Easyclimate-backend with Easyclimate.

Document Contents
-----------------------

.. toctree::
   :maxdepth: 1
   :caption: Installation

   ./src/install

.. toctree::
   :maxdepth: 1
   :caption: Building from source

   ./src/building_windows
   ./src/building_linux
   ./src/building_manylinux

.. toctree::
   :maxdepth: 1
   :caption: Modules

   ./src/module_pyspharm
   ./src/module_fftpack

.. toctree::
   :maxdepth: 1
   :caption: Reference documentation

   ./src/changelog
   ./src/contributing
   ./src/softlist

Contribute
----------

We're always looking for contributions to improve Easyclimate-backend. Please see our `Contributing <contributing.html>`_ guide for details on how you can help.

Changelog
---------

Stay up-to-date with the latest changes and improvements by checking our `Changelog <changelog.html>`_.
