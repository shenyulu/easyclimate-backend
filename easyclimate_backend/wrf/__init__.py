from __future__ import (absolute_import, division, print_function)
import os
# import pkg_resources


def _add_windows_runtime_dll_dirs():
    """Help Windows find Intel runtime DLLs installed as Python packages.

    The wheel depends on Intel runtime packages such as ``intel-fortran-rt``
    and ``intel-openmp``. On Windows, those DLLs are not always discovered
    automatically when importing the compiled extension, so we register their
    containing directories with the DLL search path before importing ``api``.
    """
    if os.name != "nt":
        return

    try:
        from importlib.metadata import PackageNotFoundError, distribution
    except ImportError:
        return

    runtime_dists = (
        "intel-fortran-rt",
        "intel-openmp",
        "intel-cmplr-lib-rt",
        "intel-cmplr-lib-ur",
        "intel-cmplr-lic-rt",
        "intel-sycl-rt",
        "dpcpp-cpp-rt",
        "impi-rt",
        "tbb",
        "tcmlib",
        "umf",
    )

    dll_dirs = []
    seen = set()

    for dist_name in runtime_dists:
        try:
            dist = distribution(dist_name)
        except PackageNotFoundError:
            continue

        files = dist.files or ()
        for path in files:
            if path.suffix.lower() != ".dll":
                continue

            dll_dir = str(dist.locate_file(path).parent)
            if dll_dir not in seen:
                seen.add(dll_dir)
                dll_dirs.append(dll_dir)

    # Keep the returned handles alive for the duration of the process.
    globals().setdefault("_dll_dir_handles", [])
    for dll_dir in dll_dirs:
        globals()["_dll_dir_handles"].append(os.add_dll_directory(dll_dir))


_add_windows_runtime_dll_dirs()

try:
    from . import api
    from .api import *
except ImportError:
    import sys
    sys.path.append(os.getcwd())
    from . import api
    from .api import *   

    # # For gfortran+msvc combination, extra shared libraries may exist
    # # (stored by numpy.distutils)
    # if os.name == "nt":
    #     req = pkg_resources.Requirement.parse("wrf-python")
    #     extra_dll_dir = pkg_resources.resource_filename(req,
    #                                                     "wrf-python/.libs")
    #     if os.path.isdir(extra_dll_dir):
    #         os.environ["PATH"] += os.pathsep + extra_dll_dir

    #     from . import api
    #     from .api import *
    # else:
    #     raise


__all__ = []
__all__.extend(api.__all__)
