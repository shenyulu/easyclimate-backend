project('_ecl_redfit_x', 'c',
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

lib = static_library('lib_ecl_redfit_x', [
                'src/nrtype.f90', 'src/nrutil.f90', 'src/mutil.f90',
                'src/nr.f90', 'src/ran.f90', 'src/ran1.f', 'src/gasdev.f'])

# Fortran source files
srcs_ecl_redfit_x =  ['redfit_x.f90',
                            'src/sort.f90', 'src/erfcc.f90',
                            'src/gser.f90', 'src/gcf.f90', 'src/avevar.f90',
                            'src/gammp.f90', 'src/gammln.f90']

# https://github.com/numpy/numpy/issues/25199
redfit_source = custom_target('_ecl_redfit_xmodule.c',
  input : ['_ecl_redfit_x.pyf'],
  output : ['_ecl_redfit_xmodule.c', '_ecl_redfit_x-f2pywrappers.f'],
  command : [py, '-m', 'numpy.f2py', '@INPUT@', '--lower', '--build-dir', 'subprojects/redfit_x']
)

py.extension_module('_ecl_redfit_x',
  srcs_ecl_redfit_x + redfit_source,
  incdir_f2py / 'fortranobject.c',
  include_directories: inc_np,
  link_with: lib,
  dependencies : py_dep,
  install : true,
  install_dir: py.get_install_dir() / 'easyclimate_backend' / 'redfit'
)
