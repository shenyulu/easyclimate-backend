Overview
======================================================


What is Easyclimate-backend?
--------------------------------------

The easyclimate-backend is designed to handle the heavy lifting for Easyclimate, 
allowing the front-end package to offer a user-friendly interface for climate analysis. 
By leveraging the speed and efficiency of ``Fortran`` and ``C``, 
The easyclimate-backend makes sure that even the most computationally intensive tasks are managed seamlessly.

.. figure:: ../_static/easyclimate_backend_logo_mini.png
   :scale: 50%
   :align: center

Key Features
----------------------

- **Aerobulk** 🌊: For bulk aerodynamic calculations, essential for understanding air-sea interactions.
- **Heat_Stress** 🌡️: Calculations related to heat stress indices, crucial for studying climate impacts on human health.
- **PySpharm** 🌍: Spherical harmonic functions for analyzing data on a sphere, perfect for global climate patterns.
- **Redfit** 📊: Tools for fitting red noise to time series data, useful in climate variability studies.
- **Windspharm** 💨: Functions for wind speed and direction calculations, vital for atmospheric dynamics.
- **WRF-Python** ⛈️: Utilities for working with output from the Weather Research and Forecasting (WRF) model.
- **NCL Functions** 🚩: Functional implementation of the NCL portion of the Fortran code.

EasyClimate Related Repositories
------------------------------------------------------------------

The EasyClimate ecosystem consists of several interconnected repositories:

.. figure:: ../_static/easyclimate_logo_mini.png
    :scale: 20%
    :align: center
    :target: https://github.com/shenyulu/easyclimate

    A line of code to analyze climate (https://github.com/shenyulu/easyclimate)

.. figure:: ../_static/easyclimate_rust_logo_mini.png
    :scale: 20%
    :align: center
    :target: https://github.com/shenyulu/easyclimate-rust

    The Rust backend of easyclimate (https://github.com/shenyulu/easyclimate-rust)

.. figure:: ../_static/easyclimate_map_logo_mini.png
    :scale: 20%
    :align: center
    :target: https://github.com/shenyulu/easyclimate-map

    Easily obtain map data (https://github.com/shenyulu/easyclimate-map)
