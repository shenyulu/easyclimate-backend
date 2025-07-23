#!/bin/bash

# Check Intel Fortran Compiler status
ifx -v

# https://mesonbuild.com/meson-python/how-to-guides/sdist.html
python -m build --no-isolation --sdist .
