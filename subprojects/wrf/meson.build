project('_wrf', 'c',
  version : '1.0.0',
  license: 'Apache-2.0',
  meson_version: '>=1.1.0',
  default_options : ['warning_level=2'],
)

is_windows = build_machine.system() == 'windows'

# Windows Build Method
if is_windows
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

  fc = meson.get_compiler('fortran')

  # Flags
  omp_flags = ['/Qopenmp', '/heap-arrays']
  omp_dep = fc.find_library('libiomp5md', required: true)

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

# Linux Build Method
else

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

  # OpenMP* Support Libraries
  # https://www.intel.com/content/www/us/en/docs/dpcpp-cpp-compiler/developer-guide-reference/2023-1/openmp-support-libraries.html
  # https://www.intel.com/content/www/us/en/docs/dpcpp-cpp-compiler/developer-guide-reference/2023-1/use-the-openmp-libraries.html
  fc = meson.get_compiler('fortran')

  omp_flags = ['-qopenmp', '-heap-arrays']
  # `dirs` is necessary in the Linux
  omp_dep = fc.find_library('libiomp5', dirs: '/opt/intel/oneapi/compiler/latest/lib', required: true)

  # Part1: lib
  lib1 = static_library('lib_wrf', ['src/wrf_constants.f90'])
  lib2 = static_library('lib_omp', ['src/omp.f90'], dependencies : [omp_dep])

  # Part2: wrf_constants
  srcs_wrf =  ['src/wrf_constants.f90']
  wrf_source = custom_target('_wrf_constantsmodule.c',
    input : ['_wrf_constants.pyf'],
    output : ['_wrf_constantsmodule.c', '_wrf_constants-f2pywrappers2.f90'],
    command : [py, '-m', 'numpy.f2py', '@INPUT@', '--lower', '--build-dir', 'subprojects/wrf']
  )
  py.extension_module('_wrf_constants',
    srcs_wrf + wrf_source,
    incdir_f2py / 'fortranobject.c',
    include_directories: inc_np,
    dependencies : [py_dep],
    install : true,
    install_dir: py.get_install_dir() / 'easyclimate_backend' / 'wrf'
  )

  # Part3: Core wrf
  # Fortran source files
  srcs_wrf =  [
    'src/calc_uh.f90', 'src/wrf_bint3d.f', 'src/wrf_cloud_fracf.f90',
    'src/wrf_fctt.f90', 'src/wrf_pvo.f90', 'src/wrf_pw.f90',
    'src/wrf_relhl.f90', 'src/wrf_rip_phys_routines.f90', 'src/wrf_user_dbz.f90',
    'src/wrf_user_latlon_routines.f90', 'src/wrf_user.f90', 'src/wrf_vinterp.f90',
    'src/wrf_wind.f90', 'src/rip_cape.f90', 'src/eqthecalc.f90',
  ]

  # https://github.com/numpy/numpy/issues/25199
  wrf_source = custom_target('_wrfmodule.c',
    input : ['_wrf.pyf'],
    output : ['_wrfmodule.c', '_wrf-f2pywrappers.f'],
    command : [py, '-m', 'numpy.f2py', '@INPUT@', '--lower', '--build-dir', 'subprojects/wrf']
  )

  py.extension_module('_wrf',
    srcs_wrf + wrf_source,
    incdir_f2py / 'fortranobject.c',
    include_directories: inc_np,
    link_with: [lib1, lib2],
    fortran_args: omp_flags,
    dependencies : [py_dep, omp_dep],
    install : true,
    install_dir: py.get_install_dir() / 'easyclimate_backend' / 'wrf'
  )

endif