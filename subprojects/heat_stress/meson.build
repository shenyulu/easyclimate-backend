project('heat_stress', 'c',
  version : '1.0.0',
  meson_version: '>=1.1.0',
  default_options : ['warning_level=2'],
)

# HumanIndexMod
# ----------------------------------------------
add_languages('fortran', native: false)

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

srcs_spherepack = ['human_index_mod_2020/human_index_mod.f90']

# https://github.com/numpy/numpy/issues/25199
spherepack_source = custom_target('human_index_modmodule.c',
  input : ['human_index_mod_2020/human_index_mod.pyf'],
  output : ['human_index_modmodule.c', 'human_index_mod-f2pywrappers.f'],
  command : [py, '-m', 'numpy.f2py', '@INPUT@', '--lower', '--build-dir', 'subprojects/heat_stress']
)

py.extension_module('human_index_mod',
  srcs_spherepack + spherepack_source,
  incdir_f2py / 'fortranobject.c',
  include_directories: inc_np,
  dependencies : py_dep,
  install : true,
  install_dir: py.get_install_dir() / 'easyclimate_backend' / 'heat_stress'
)

# HumanIndexModOld
# ----------------------------------------------
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

srcs_spherepack = ['human_index_mod_2020/human_index_mod_old.f90']

# https://github.com/numpy/numpy/issues/25199
spherepack_source = custom_target('human_index_mod_oldmodule.c',
  input : ['human_index_mod_2020/human_index_mod_old.pyf'],
  output : ['human_index_mod_oldmodule.c', 'human_index_mod_old-f2pywrappers.f'],
  command : [py, '-m', 'numpy.f2py', '@INPUT@', '--lower', '--build-dir', 'subprojects/heat_stress']
)

py.extension_module('human_index_mod_old',
  srcs_spherepack + spherepack_source,
  incdir_f2py / 'fortranobject.c',
  include_directories: inc_np,
  dependencies : py_dep,
  install : true,
  install_dir: py.get_install_dir() / 'easyclimate_backend' / 'heat_stress'
)