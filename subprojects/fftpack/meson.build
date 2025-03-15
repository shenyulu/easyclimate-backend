project('_fftpack', 'c',
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
srcs_fftpack =  [
  'src/c1f2kb.f','src/c1f2kf.f','src/c1f3kb.f','src/c1f3kf.f','src/c1f4kb.f','src/c1f4kf.f','src/c1f5kb.f',
  'src/c1f5kf.f','src/c1fgkb.f','src/c1fgkf.f','src/c1fm1b.f','src/c1fm1f.f','src/cfft1b.f','src/cfft1f.f',
  'src/cfft1i.f','src/cfft2b.f','src/cfft2f.f','src/cfft2i.f','src/cfftmb.f','src/cfftmf.f','src/cfftmi.f',
  'src/cmf2kb.f','src/cmf2kf.f','src/cmf3kb.f','src/cmf3kf.f','src/cmf4kb.f','src/cmf4kf.f','src/cmf5kb.f',
  'src/cmf5kf.f','src/cmfgkb.f','src/cmfgkf.f','src/cmfm1b.f','src/cmfm1f.f','src/cosq1b.f','src/cosq1f.f',
  'src/cosq1i.f','src/cosqb1.f','src/cosqf1.f','src/cosqmb.f','src/cosqmf.f','src/cosqmi.f','src/cost1b.f',
  'src/cost1f.f','src/cost1i.f','src/costb1.f','src/costf1.f','src/costmb.f','src/costmf.f','src/costmi.f',
  'src/factor.f','src/mcfti1.f','src/mcsqb1.f','src/mcsqf1.f','src/mcstb1.f','src/mcstf1.f','src/mradb2.f',
  'src/mradb3.f','src/mradb4.f','src/mradb5.f','src/mradbg.f','src/mradf2.f','src/mradf3.f','src/mradf4.f',
  'src/mradf5.f','src/mradfg.f','src/mrftb1.f','src/mrftf1.f','src/mrfti1.f','src/msntb1.f','src/msntf1.f',
  'src/r1f2kb.f','src/r1f2kf.f','src/r1f3kb.f','src/r1f3kf.f','src/r1f4kb.f','src/r1f4kf.f','src/r1f5kb.f',
  'src/r1f5kf.f','src/r1fgkb.f','src/r1fgkf.f','src/r2w.f','src/rfft1b.f','src/rfft1f.f','src/rfft1i.f',
  'src/rfft2b.f','src/rfft2f.f','src/rfft2i.f','src/rfftb1.f','src/rfftf1.f','src/rffti1.f','src/rfftmb.f',
  'src/rfftmf.f','src/rfftmi.f','src/sinq1b.f','src/sinq1f.f','src/sinq1i.f','src/sinqmb.f','src/sinqmf.f',
  'src/sinqmi.f','src/sint1b.f','src/sint1f.f','src/sint1i.f','src/sintb1.f','src/sintf1.f','src/sintmb.f',
  'src/sintmf.f','src/sintmi.f','src/tables.f','src/w2r.f','src/xercon.f','src/xerfft.f']


# https://github.com/numpy/numpy/issues/25199
spherepack_source = custom_target('_fftpackmodule.c',
  input : ['_fftpack.pyf'],
  output : ['_fftpackmodule.c', '_fftpack-f2pywrappers.f'],
  command : [py, '-m', 'numpy.f2py', '@INPUT@', '--lower', '--build-dir', 'subprojects/fftpack']
)

py.extension_module('_fftpack',
  srcs_fftpack + spherepack_source,
  incdir_f2py / 'fortranobject.c',
  include_directories: inc_np,
  dependencies : py_dep,
  install : true,
  install_dir: py.get_install_dir() / 'easyclimate_backend' / 'fftpack'
)
