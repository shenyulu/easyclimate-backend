project('_wrf', 'c',
  version : '1.0.0',
  license: 'Apache-2.0',
  meson_version: '>=1.1.0',
  default_options : ['warning_level=2'],
)

add_languages('fortran', , native: false)

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

fc = meson.get_compiler('fortran')
is_windows = build_machine.system() == 'windows'

# Flags
if is_windows
  omp_flags = ['/Qopenmp', '/heap-arrays']
  omp_dep = fc.find_library('libiomp5md', required: true)
else
  omp_flags = ['-qopenmp', '-heap-arrays']
  omp_dep = fc.find_library('libiomp5', dirs: '/opt/intel/oneapi/compiler/latest/lib', required: true)
endif

# Part1: omp_constants module (只有 .c 文件，没有包装文件)
py.extension_module('_omp_constants',
  'src/omp.f90',
  '_omp_constantsmodule.c',
  incdir_f2py / 'fortranobject.c',
  include_directories: inc_np,
  fortran_args: omp_flags,
  dependencies : [py_dep, omp_dep],
  install : true,
  install_dir: py.get_install_dir() / 'easyclimate_backend' / 'wrf'
)

# Part2: wrf_constants module (有 .c 和 .f90 包装文件)
py.extension_module('_wrf_constants',
  'src/wrf_constants.f90',
  '_wrf_constantsmodule.c',
  '_wrf_constants-f2pywrappers2.f90',
  incdir_f2py / 'fortranobject.c',
  include_directories: inc_np,
  dependencies : [py_dep],
  install : true,
  install_dir: py.get_install_dir() / 'easyclimate_backend' / 'wrf'
)

# Part3: Core wrf module (有 .c、.f 和 .f90 包装文件)
srcs_wrf = [
  'src/omp.f90',
  'src/wrf_constants.f90',
  'src/calc_uh.f90', 'src/wrf_bint3d.f', 'src/wrf_cloud_fracf.f90',
  'src/wrf_fctt.f90', 'src/wrf_pvo.f90', 'src/wrf_pw.f90',
  'src/wrf_relhl.f90', 'src/wrf_rip_phys_routines.f90', 'src/wrf_user_dbz.f90',
  'src/wrf_user_latlon_routines.f90', 'src/wrf_user.f90', 'src/wrf_vinterp.f90',
  'src/wrf_wind.f90', 'src/rip_cape.f90', 'src/eqthecalc.f90',
  '_wrfmodule.c',
  '_wrf-f2pywrappers.f',
  '_wrf-f2pywrappers2.f90',
  incdir_f2py / 'fortranobject.c',
]

py.extension_module('_wrf',
  srcs_wrf,
  include_directories: inc_np,
  fortran_args: omp_flags,
  dependencies : [py_dep, omp_dep],
  install : true,
  install_dir: py.get_install_dir() / 'easyclimate_backend' / 'wrf'
)