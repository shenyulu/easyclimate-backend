"""Spherical harmonic vector wind analysis."""
# Copyright (c) 2012-2018 Andrew Dawson
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
from __future__ import absolute_import

from . import standard
from . import tools

from ._version import get_versions
__version__ = get_versions()['version']
del get_versions


# List to define the behaviour of imports of the form:
#     from windspharm import *
__all__ = []

try:
    from . import cdms
    __all__.append('cdms')
    metadata = cdms
except ImportError:
    pass

try:
    from . import iris
    __all__.append('iris')
except ImportError:
    pass

try:
    from . import xarray
    __all__.append('xarray')
except ImportError:
    pass
