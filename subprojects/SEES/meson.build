project('_ecl_fastcompute', 'c',
  version : '1.0.0',
  license: 'BSD-3',
  meson_version: '>=1.1.0',
  default_options : ['warning_level=2'],
)

add_languages('fortran')

py_mod = import('python')

py = py_mod.find_installation(pure: false)
py_dep = py.dependency()

incdir_numpy = run_command(py,
  ['-c', 'import os; os.chdir(".."); import numpy; print(numpy.get_include())'],
  check : true
).stdout().strip()

incdir_f2py = run_command(py,
    ['-c', 'import os; os.chdir(".."); import numpy.f2py; print(numpy.f2py.get_include())'],
    check : true
).stdout().strip()

inc_np = include_directories(incdir_numpy, incdir_f2py)

# Fortran source files
srcs_local = ['SE_eqn_coreV3.3.f90']

# https://github.com/numpy/numpy/issues/25199
_ecl_fastcompute_source = custom_target('_ecl_fastcomputemodule.c',
  input : ['_ecl_fastcompute.pyf'],
  output : ['_ecl_fastcomputemodule.c', '_ecl_fastcompute-f2pywrappers.f'],
  command : [py, '-m', 'numpy.f2py', '@INPUT@', '--lower', '--build-dir', 'subprojects/SEES']
)

py.extension_module('_ecl_fastcompute',
  srcs_local + _ecl_fastcompute_source,
  incdir_f2py / 'fortranobject.c',
  include_directories: inc_np,
  dependencies : py_dep,
  install : true,
  install_dir: py.get_install_dir() / 'easyclimate_backend' / 'sees'
)
