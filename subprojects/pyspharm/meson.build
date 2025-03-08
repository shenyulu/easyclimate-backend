project('_spherepack', 'c',
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
srcs_spherepack =  ['src/gaqd.f','src/shses.f','src/shaes.f',
                    'src/vhaes.f','src/vhses.f','src/shsgs.f',
                    'src/shags.f','src/vhags.f','src/vhsgs.f',
                    'src/sphcom.f','src/hrfft.f','src/shaec.f',
                    'src/shagc.f','src/shsec.f','src/shsgc.f',
                    'src/vhaec.f','src/vhagc.f','src/vhsec.f',
                    'src/vhsgc.f','src/ihgeod.f','src/alf.f']

srcs_local = ['src/getlegfunc.f', 'src/specintrp.f','src/onedtotwod.f',
              'src/onedtotwod_vrtdiv.f','src/twodtooned.f','src/twodtooned_vrtdiv.f',
              'src/multsmoothfact.f','src/lap.f','src/invlap.f']

# https://github.com/numpy/numpy/issues/25199
spherepack_source = custom_target('_spherepackmodule.c',
  input : ['_spherepack.pyf'],
  output : ['_spherepackmodule.c', '_spherepack-f2pywrappers.f'],
  command : [py, '-m', 'numpy.f2py', '@INPUT@', '--lower', '--build-dir', 'subprojects/pyspharm']
)

py.extension_module('_spherepack',
  srcs_local + srcs_spherepack + spherepack_source,
  incdir_f2py / 'fortranobject.c',
  include_directories: inc_np,
  dependencies : py_dep,
  install : true,
  install_dir: py.get_install_dir() / 'easyclimate_backend' / 'pyspharm'
)
