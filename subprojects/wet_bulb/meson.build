project('_wet_bulb_temperature', 'c',
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

# Fortran source files
srcs_local = ['wet_bulb_temperature.f90']

# https://github.com/numpy/numpy/issues/25199
_wet_bulb_temperature_source = custom_target('_wet_bulb_temperaturemodule.c',
  input : ['_wet_bulb_temperature.pyf'],
  output : ['_wet_bulb_temperaturemodule.c', '_wet_bulb_temperature-f2pywrappers.f'],
  command : [py, '-m', 'numpy.f2py', '@INPUT@', '--lower', '--build-dir', 'subprojects/wet_bulb']
)

py.extension_module('_wet_bulb_temperature',
  srcs_local + _wet_bulb_temperature_source,
  incdir_f2py / 'fortranobject.c',
  include_directories: inc_np,
  dependencies : py_dep,
  install : true,
  install_dir: py.get_install_dir() / 'easyclimate_backend' / 'wet_bulb'
)
