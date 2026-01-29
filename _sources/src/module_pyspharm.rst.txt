.. _module_pyspharm:

Pyspharm
============

Introduction
------------
This module provides a Python interface to the NCAR SPHEREPACK library. It is designed for working with atmospheric general circulation model (GCM) data and supports various spherical harmonic transformations and interpolations.

.. tip::

    https://github.com/jswhit/pyspharm

You can introduce the ``Pyspharm`` package built into ``easyclimate-backend`` in the following way:

.. code-block:: python

   from easyclimate_backend.pyspharm import spharm

Official documentation
-------------------------

.. raw:: html

   <iframe src="raw/pyspharm/index.html" width="100%" height="500px"></iframe>

Functions
---------

1. gaussian_lats_wts
~~~~~~~~~~~~~~~~~~~~
Computes Gaussian latitudes (in degrees) and their corresponding quadrature weights.

.. code-block:: python

    from easyclimate_backend.pyspharm import spharm

    nlat = 72  # Number of latitude points
    lats, wts = spharm.gaussian_lats_wts(nlat)

    print("Gaussian latitudes (degrees):", lats)
    print("Quadrature weights:", wts)

.. note::

    - Gaussian latitudes are ordered from the North Pole to the South Pole.
    - Weights are used for Gaussian integration and should be multiplied by the longitude interval (e.g., ``2π/nlon``).

2. getgeodesicpts
~~~~~~~~~~~~~~~~~
Computes the latitudes and longitudes of points on a twenty-sided (icosahedral) geodesic grid.

.. code-block:: python

    from easyclimate_backend.pyspharm import spharm

    m = 10  # Number of points on each edge of a geodesic triangle
    lats, lons = spharm.getgeodesicpts(m)

    print("Geodesic point latitudes (degrees):", lats)
    print("Geodesic point longitudes (degrees):", lons)

.. admonition:: Use Case
    :class: tip

    Generating unstructured grid points for interpolation.


3. getspecindx
~~~~~~~~~~~~~~
Computes indices for zonal wavenumber (``m``) and degree (``n``) of spherical harmonic coefficients.

.. code-block:: python

    from easyclimate_backend.pyspharm import spharm

    ntrunc = 42  # Truncation wavenumber (e.g., T42)
    indxm, indxn = spharm.getspecindx(ntrunc)

    # Example: View the first 10 coefficients' m and n
    for i in range(10):
        print(f"Index {i}: m={indxm[i]}, n={indxn[i]}")

.. admonition:: Purpose
    :class: tip

    Resolves the physical meaning of each element in the spectral coefficient array.



4. legendre
~~~~~~~~~~~
Computes associated Legendre functions at a specified latitude and truncation wavenumber.


.. code-block:: python

    from easyclimate_backend.pyspharm import spharm

    lat = 45.0  # Latitude (degrees)
    ntrunc = 42  # Truncation wavenumber
    pnm = spharm.legendre(lat, ntrunc)

    print("Shape of Legendre function values:", pnm.shape)  # (ntrunc+1)*(ntrunc+2)/2

.. note::

    Results are used for spectral interpolation (e.g., ``specintrp``) or custom spectral synthesis.

5. regrid
~~~~~~~~~
Regrids data from an input grid to an output grid, with optional spectral truncation or smoothing.


.. code-block:: python

    from easyclimate_backend.pyspharm import spharm
    import numpy as np

    # Initialize input and output grids
    sph_in = spharm.Spharmt(144, 72, gridtype='gaussian')  # Input Gaussian grid
    sph_out = spharm.Spharmt(128, 64, gridtype='regular')   # Output regular grid

    # Simulate input data (72x144)
    data_in = np.random.rand(72, 144)

    # Perform regridding (automatically truncates to output grid's ntrunc)
    data_out = spharm.regrid(sph_in, sph_out, data_in)

    print("Output data shape:", data_out.shape)  # (64, 128)


.. admonition:: Smoothing Option
    :class: tip

    Pass a ``smooth`` array to define smoothing factors for each wavenumber.


6. specintrp
~~~~~~~~~~~~
Performs spectral interpolation at arbitrary points on the sphere.


.. code-block:: python

    from easyclimate_backend.pyspharm import spharm
    import numpy as np

    # Initialize Spharmt instance
    sph = spharm.Spharmt(144, 72, gridtype='gaussian')

    # Generate simulated spectral coefficients (assume converted via grdtospec)
    spec_coeff = sph.grdtospec(np.random.rand(72, 144))

    # Compute Legendre functions at target latitude (e.g., 45°N)
    lat_target = 45.0
    pnm = spharm.legendre(lat_target, sph.ntrunc)

    # Interpolate at longitude 90°E
    lon_target = 90.0
    value = spharm.specintrp(lon_target, spec_coeff, pnm)

    print("Interpolated value at point:", value)

.. note::
    
    Legendre functions at the target latitude must be precomputed.


7. Spharmt Class Methods
------------------------

7.1 spectogrd
~~~~~~~~~~~~~
Transforms spectral coefficients to grid data.


.. code-block:: python

    spec_coeff = sph.grdtospec(grid_data)  # Assume spectral coefficients are available
    grid_reconstructed = sph.spectogrd(spec_coeff)


7.2 getuv
~~~~~~~~~
Computes wind components from vorticity and divergence.


.. code-block:: python

    # Assume vort_spec and div_spec are spectral coefficients of vorticity and divergence
    u, v = sph.getuv(vort_spec, div_spec)


7.3 getvrtdivspec
~~~~~~~~~~~~~~~~~
Computes vorticity and divergence from wind components.


.. code-block:: python

    # Assume u_grid and v_grid are grid wind components
    vort_spec, div_spec = sph.getvrtdivspec(u_grid, v_grid)



7.4 getgrad
~~~~~~~~~~~
Computes the gradient of a scalar field.


.. code-block:: python

    # Assume scalar_spec is the spectral coefficients of a scalar field (e.g., height field)
    ug, vg = sph.getgrad(scalar_spec)


7.5 getpsichi
~~~~~~~~~~~~~
Computes streamfunction and velocity potential from wind components.


.. code-block:: python

    psi_spec, chi_spec = sph.getpsichi(u_grid, v_grid)



7.6 specsmooth
~~~~~~~~~~~~~~
Applies spectral smoothing.


.. code-block:: python

    smoothed_spec = sph.specsmooth(spec_coeff, smooth_factors)



Key Notes
---------

1. **Grid Orientation**:

   - Grid data latitudes are ordered from the North Pole to the South Pole by default.
   - Longitudes start at 0°E and increase eastward.

2. **Spectral Coefficient Order**:

   - Spectral coefficients are arranged in a 1D array of size ``(ntrunc+1)*(ntrunc+2)/2``, and their wavenumbers can be resolved using ``getspecindx``.

3. **Performance Optimization**:

   - Use ``legfunc='stored'`` to speed up repeated method calls, but this increases memory usage.



Conclusion
----------
With the above functions and examples, the ``spharm`` module can be used for spherical harmonic analysis, synthesis, interpolation, and physical quantity calculations.

