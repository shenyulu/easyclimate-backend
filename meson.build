# Manual build guide
# 
# meson setup builddir --buildtype=release
# meson compile -C builddir 

project('easyclimate-backend', 'c',
  version : '2025.3.0',
  license: 'BSD-3',
  meson_version: '>=1.1.0',
  default_options : ['warning_level=2'],
)

# Windows and linux cross-compile configuration
if host_machine.system() == 'windows'
  add_global_arguments('-DNO_APPEND_FORTRAN', language : 'fortran')
  add_global_arguments('-DUPPERCASE_FORTRAN', language : 'fortran')
  add_global_arguments('-DNO_APPEND_FORTRAN', language : 'c')
  add_global_arguments('-DUPPERCASE_FORTRAN', language : 'c')
endif

py_mod = import('python')
py = py_mod.find_installation(pure: false)

subproject('redfit')
subproject('redfit_x')
subproject('SEES')
subproject('pyspharm')
subproject('fftpack')
subproject('heat_stress')
subproject('wrf')
subproject('aerobulk')

install_subdir(
    'easyclimate_backend',
    install_dir: py.get_install_dir(),
    exclude_directories: ['__pycache__'],
    exclude_files: ['test_*.py'],
    strip_directory: false
)