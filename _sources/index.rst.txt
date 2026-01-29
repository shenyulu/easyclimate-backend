.. easyclimate-backend documentation master file, created by
   sphinx-quickstart on Fri Feb 21 21:48:45 2025.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

.. title:: Home

========
|banner|
========

.. |banner| image:: _static/easyclimate_backend_logo_mini.png
    :alt: Easy-climate Backend Documentation
    :align: middle

.. raw:: html

    <p class="lead centered front-page-callout">
        Powerhouse behind the
        <a href="https://easyclimate.readthedocs.io/" target="_blank" rel="noopener noreferrer">
            easyclimate
        </a>
        front-end package
        <br>
        <strong>High-performance, low-level functions for climate data analysis</strong>
    </p>


You can directly install it via `pip` by using 🛒

.. code-block:: bash

    $ pip install easyclimate-backend


.. warning::

   🚨 This package is still undergoing rapid development. 🚨

   All of the API (functions/classes/interfaces) is subject to change. 
   There may be non-backward compatible changes as we experiment with new design ideas and implement new features. 
   This is not a finished product, use with caution.

.. toctree::
   :maxdepth: 1
   :hidden:
   :caption: Getting Started

   ./src/overview
   ./src/install

.. toctree::
   :maxdepth: 1
   :hidden:
   :caption: Building from source

   ./src/building_windows
   ./src/building_linux
   ./src/building_manylinux

.. toctree::
   :maxdepth: 1
   :hidden:
   :caption: Modules

   ./src/module_pyspharm

.. toctree::
   :maxdepth: 1
   :hidden:
   :caption: Reference documentation

   ./src/changelog
   ./src/contributing
   ./src/softlist
