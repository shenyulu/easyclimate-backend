project('_vibeta', 'c',
  version : '1.0.0',
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

# ----------------------------------------------
# vibeta_dp
# ----------------------------------------------

# Fortran source files
srcs_local = ['src/vibeta_dp.f']

# https://github.com/numpy/numpy/issues/25199
spherepack_source = custom_target('_vibeta_dpmodule.c',
  input : ['_vibeta_dp.pyf'],
  output : ['_vibeta_dpmodule.c', '_vibeta_dp-f2pywrappers.f'],
  command : [py, '-m', 'numpy.f2py', '@INPUT@', '--lower', '--build-dir', 'subprojects/vibeta']
)

py.extension_module('_vibeta_dp',
  srcs_local + spherepack_source,
  incdir_f2py / 'fortranobject.c',
  include_directories: inc_np,
  dependencies : [py_dep],
  install : true,
  install_dir: py.get_install_dir() / 'easyclimate_backend' / 'vibeta'
)
