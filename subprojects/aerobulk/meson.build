project('aerobulk', 'c',
  version : '1.0.0',
  meson_version: '>=1.1.0',
  default_options : ['warning_level=2'],
)

# mod_aerobulk_wrap_noskin
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

srcs_pack = [
    'src/mod_const.f90',
    'src/mod_phymbl.f90',
    'src/mod_skin_coare.f90',
    'src/mod_skin_ecmwf.f90',
    'src/mod_blk_andreas.f90',
    'src/mod_common_coare.f90',
    'src/mod_blk_coare3p0.f90',
    'src/mod_blk_coare3p6.f90',
    'src/mod_blk_ecmwf.f90',
    'src/mod_blk_ncar.f90',
    'src/mod_blk_neutral_10m.f90',
    'src/mod_aerobulk_compute.f90',
    'src/mod_aerobulk.f90',
    'mod_aerobulk_wrap_noskin.f90',
]

# https://github.com/numpy/numpy/issues/25199
pack_source = custom_target('mod_aerobulk_wrap_noskinmodule.c',
  input : ['mod_aerobulk_wrap_noskin.pyf'],
  output : ['mod_aerobulk_wrap_noskinmodule.c', 'mod_aerobulk_wrap_noskin-f2pywrappers2.f90'],
  command : [py, '-m', 'numpy.f2py', '@INPUT@', '--lower', '--build-dir', 'subprojects/aerobulk']
)

py.extension_module('mod_aerobulk_wrap_noskin',
  srcs_pack + pack_source,
  incdir_f2py / 'fortranobject.c',
  include_directories: inc_np,
  dependencies : py_dep,
  install : true,
  install_dir: py.get_install_dir() / 'easyclimate_backend' / 'aerobulk'
)

# mod_aerobulk_wrap_skin
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

srcs_pack = [
    'src/mod_const.f90',
    'src/mod_phymbl.f90',
    'src/mod_skin_coare.f90',
    'src/mod_skin_ecmwf.f90',
    'src/mod_blk_andreas.f90',
    'src/mod_common_coare.f90',
    'src/mod_blk_coare3p0.f90',
    'src/mod_blk_coare3p6.f90',
    'src/mod_blk_ecmwf.f90',
    'src/mod_blk_ncar.f90',
    'src/mod_blk_neutral_10m.f90',
    'src/mod_aerobulk_compute.f90',
    'src/mod_aerobulk.f90',
    'mod_aerobulk_wrap_skin.f90',
]

# https://github.com/numpy/numpy/issues/25199
pack_source = custom_target('mod_aerobulk_wrap_skinmodule.c',
  input : ['mod_aerobulk_wrap_skin.pyf'],
  output : ['mod_aerobulk_wrap_skinmodule.c', 'mod_aerobulk_wrap_skin-f2pywrappers2.f90'],
  command : [py, '-m', 'numpy.f2py', '@INPUT@', '--lower', '--build-dir', 'subprojects/aerobulk']
)

py.extension_module('mod_aerobulk_wrap_skin',
  srcs_pack + pack_source,
  incdir_f2py / 'fortranobject.c',
  include_directories: inc_np,
  dependencies : py_dep,
  install : true,
  install_dir: py.get_install_dir() / 'easyclimate_backend' / 'aerobulk'
)