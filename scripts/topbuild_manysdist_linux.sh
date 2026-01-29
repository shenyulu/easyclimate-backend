#!/bin/bash
export CC=gcc
export FC=ifx

# Check Intel Fortran Compiler status
ifx -v

# https://mesonbuild.com/meson-python/how-to-guides/sdist.html
python -m build --no-isolation --sdist .
