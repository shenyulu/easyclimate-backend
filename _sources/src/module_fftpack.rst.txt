.. _module_fftpack:

FFTPACK
===============================

Overview and Background
-----------------------

FFTPACK is a Fortran library designed for performing fast Fourier transforms (FFT) and related transformations. Initially developed by Paul Swarztrauber and Dick Valent at the National Center for Atmospheric Research (NCAR), FFTPACK version 5.1 is widely recognized for its efficiency in scientific computing, particularly in signal processing, numerical analysis, and atmospheric research. Sponsored by the National Science Foundation, this library provides subroutines for transforming real and complex data, including one-dimensional (1D), two-dimensional (2D), and multiple-sequence transforms.

The Python module `_fftpack`, generated via F2PY, serves as an interface to FFTPACK's Fortran subroutines, enabling seamless integration into Python environments like NumPy. This documentation assumes the module is imported as ``import _fftpack`` and focuses on its practical usage in Python, including initialization, forward, and backward transforms for various data types.

Key Features:

- **Supported Transforms**: Complex FFT, Real FFT, Cosine Transform, Sine Transform, Quarter-Wave Cosine, and Quarter-Wave Sine transforms.
- **Dimensions**: 1D, 2D, and multiple-sequence transforms.
- **Efficiency**: Optimized for sequences whose lengths are products of small primes.
- **Normalization**: All transforms are normalized, ensuring reversibility within algorithmic constraints.

.. tip::

    - https://github.com/NCAR/NCAR-Classic-Libraries-for-Geophysics
    - https://ncar-hpc-docs.readthedocs.io/en/latest/environment-and-software/ncar-classic-libraries-for-geophysics/

Official documentation
-------------------------

.. raw:: html

   <iframe src="raw/fftpack/FFTPACK5.1.html" width="100%" height="500px"></iframe>

FFTPACK5 tutorial
::::::::::::::::::::::::::::::

.. raw:: html

   <iframe src="raw/fftpack/FFTPACK5 Tutorial.pdf" width="100%" height="500px"></iframe>

:download:`Download FFTPACK5 tutorial <raw/fftpack/FFTPACK5 Tutorial.pdf>`.

FFTPACK abstract
::::::::::::::::::::::::::::::

.. raw:: html

   <iframe src="raw/fftpack/FFTPACK Abstract.pdf" width="100%" height="500px"></iframe>

:download:`Download FFTPACK abstract <raw/fftpack/FFTPACK Abstract.pdf>`.

FFTPack tutorial
::::::::::::::::::::::::::::::

.. raw:: html

   <iframe src="raw/fftpack/FFTPack_Tutorial.pdf" width="100%" height="500px"></iframe>

:download:`Download FFTPack tutorial <raw/fftpack/FFTPack_Tutorial.pdf>`.

FFTPACK5 documentation
::::::::::::::::::::::::::::::

.. raw:: html

   <iframe src="raw/fftpack/FFTPACK5 DOCUMENTATION.pdf" width="100%" height="500px"></iframe>

:download:`Download FFTPACK5 documentation <raw/fftpack/FFTPACK5 DOCUMENTATION.pdf>`.

Mathematical Principles
-----------------------

FFTPACK leverages the Fast Fourier Transform (FFT) algorithm, which reduces the computational complexity of the Discrete Fourier Transform (DFT) 
from :math:`O(N^2)` to :math:`O(N log N)`. The core idea exploits the periodicity and symmetry of trigonometric functions. 
Below is a brief overview of the mathematical foundation for key transforms:

1. Complex FFTPACK
::::::::::::::::::::::::::::::

- **Forward Transform**: Converts a time-domain sequence to the frequency domain:
    .. math::
        X(k) = \sum_{n=0}^{N-1} x(n) e^{-i 2\pi kn / N}
- **Backward Transform**: Reverts to the time domain:
    .. math::
        x(n) = \sum_{k=0}^{N-1} X(k) e^{i 2\pi kn / N}
- Normalization ensures that applying forward followed by backward transforms recovers the original sequence (up to roundoff error).

2. Real FFT
::::::::::::::::::::::::::::::

- Optimized for real-valued inputs, exploiting conjugate symmetry to store only half the frequency components.
- Forward: :math:`X(k) = \sum_{n=0}^{N-1} x(n) \cos(2\pi kn / N) - i \sin(2\pi kn / N)`

3. Cosine and Sine Transforms
::::::::::::::::::::::::::::::

- Used for even (cosine) and odd (sine) symmetry data, respectively.
- Cosine: :math:`X(k) = \sum_{n=0}^{N-1} x(n) \cos(\pi kn / (N-1))`
- Sine: :math:`X(k) = \sum_{n=1}^{N} x(n) \sin(\pi kn / (N+1))`

4. Quarter-Wave Transforms
::::::::::::::::::::::::::::::

- Specialized for odd wave numbers, useful in boundary value problems:
    - Quarter-Cosine: :math:`X(k) = \sum_{n=0}^{N-1} x(n) \cos((2n+1)k\pi / (2N))`
    - Quarter-Sine: :math:`X(k) = \sum_{n=1}^{N} x(n) \sin((2n-1)k\pi / (2N))`

For detailed derivations, refer to Swarztrauber's works: *Vectorizing the Fast Fourier Transforms* (1982) and *Fast Fourier Transforms Algorithms for Vector Computers* (1984).

Usage in Python
---------------

The `_fftpack` module requires NumPy for array operations. All subroutines follow a triplet structure: initialization (suffix `i`), forward transform (suffix `f`), and backward transform (suffix `b`). Below are detailed usage instructions and examples.

.. code-block:: python

    from easyclimate_backend import _fftpack
    import numpy as np

1. Complex Transforms
::::::::::::::::::::::::::::::

1.1 One-Dimensional Complex FFT
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Initialization**: ``cfft1i``
  - Prepares the work array `wsave`.
  - Example:

.. code-block:: python

    n = 16
    lensav = 2 * n + int(np.log(n) / np.log(2)) + 4
    wsave = np.zeros(lensav, dtype=np.float32)
    ier = _fftpack.cfft1i(n, wsave)


- **Backward Transform**: ``cfft1b`` (Frequency to Time)
  - Example:

.. code-block:: python

    c = np.random.rand(n).astype(np.complex64)
    lenc = n
    lenwrk = 2 * n
    work = np.zeros(lenwrk, dtype=np.float32)
    ier = _fftpack.cfft1b(n, 1, c, lenc, wsave, lensav, work, lenwrk)


- **Forward Transform**: ``cfft1f`` (Time to Frequency)
  - Example:

.. code-block:: python

    c = np.random.rand(n).astype(np.complex64)
    ier = _fftpack.cfft1f(n, 1, c, lenc, wsave, lensav, work, lenwrk)

1.2 Two-Dimensional Complex FFT
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Initialization**: ``cfft2i``
  - Example:

.. code-block:: python

    l, m = 16, 16
    lensav = 2 * (l + m) + int(np.log(l) / np.log(2)) + int(np.log(m) / np.log(2)) + 8
    wsave = np.zeros(lensav, dtype=np.float32)
    ier = _fftpack.cfft2i(l, m, wsave)


- **Backward Transform**: ``cfft2b``
  - Example:

.. code-block:: python

    c = np.random.rand(l, m).astype(np.complex64)
    ldim = l
    lenwrk = 2 * l * m
    work = np.zeros(lenwrk, dtype=np.float32)
    ier = _fftpack.cfft2b(ldim, l, m, c, wsave, lensav, work, lenwrk)


- **Forward Transform**: ``cfft2f``
  - Example:

.. code-block:: python

    c = np.random.rand(l, m).astype(np.complex64)
    ier = _fftpack.cfft2f(ldim, l, m, c, wsave, lensav, work, lenwrk)

1.3 Multiple Complex FFT
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Initialization**: ``cfftmi``
  - Example:

.. code-block:: python

    n = 16
    lensav = 2 * n + int(np.log(n) / np.log(2)) + 4
    wsave = np.zeros(lensav, dtype=np.float32)
    ier = _fftpack.cfftmi(n, wsave)


- **Backward Transform**: ``cfftmb``
  - Example:

.. code-block:: python

    lot = 10
    c = np.random.rand(lot * n).astype(np.complex64)
    lenc = lot * n
    lenwrk = 2 * lot * n
    work = np.zeros(lenwrk, dtype=np.float32)
    ier = _fftpack.cfftmb(lot, 1, n, 1, c, lenc, wsave, lensav, work, lenwrk)

- **Forward Transform**: ``cfftmf``
  - Example:

.. code-block:: python

    c = np.random.rand(lot * n).astype(np.complex64)
    ier = _fftpack.cfftmf(lot, 1, n, 1, c, lenc, wsave, lensav, work, lenwrk)

2. Real Transforms
::::::::::::::::::::::::::::::

2.1 One-Dimensional Real FFT
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Initialization**: ``rfft1i``
  - Example:

.. code-block:: python

    n = 16
    lensav = n + int(np.log(n) / np.log(2)) + 4
    wsave = np.zeros(lensav, dtype=np.float32)
    ier = _fftpack.rfft1i(n, wsave)


- **Backward Transform**: ``rfft1b``
  - Example:

.. code-block:: python

    r = np.random.rand(n).astype(np.float32)
    lenr = n
    lenwrk = n
    work = np.zeros(lenwrk, dtype=np.float32)
    ier = _fftpack.rfft1b(n, 1, r, lenr, wsave, lensav, work, lenwrk)


- **Forward Transform**: ``rfft1f``
  - Example:

.. code-block:: python

    r = np.random.rand(n).astype(np.float32)
    ier = _fftpack.rfft1f(n, 1, r, lenr, wsave, lensav, work, lenwrk)

2.2 Two-Dimensional Real FFT
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Initialization**: ``rfft2i``
  - Example:

.. code-block:: python

    l, m = 16, 16
    lensav = l + 3 * m + int(np.log(l) / np.log(2)) + 2 * int(np.log(m) / np.log(2)) + 12
    wsave = np.zeros(lensav, dtype=np.float32)
    ier = _fftpack.rfft2i(l, m, wsave)


- **Backward Transform**: ``rfft2b``
  - Example:

.. code-block:: python

    r = np.random.rand(l, m).astype(np.float32)
    ldim = l
    lenwrk = (l + 1) * m
    work = np.zeros(lenwrk, dtype=np.float32)
    ier = _fftpack.rfft2b(ldim, l, m, r, wsave, lensav, work, lenwrk)


- **Forward Transform**: ``rfft2f``
  - Example:

.. code-block:: python

    r = np.random.rand(l, m).astype(np.float32)
    ier = _fftpack.rfft2f(ldim, l, m, r, wsave, lensav, work, lenwrk)

2.3 Multiple Real FFT
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Initialization**: ``rfftmi``
  - Example:

.. code-block:: python

    n = 16
    lensav = n + int(np.log(n) / np.log(2)) + 4
    wsave = np.zeros(lensav, dtype=np.float32)
    ier = _fftpack.rfftmi(n, wsave)


- **Backward Transform**: ``rfftmb``
  - Example:

.. code-block:: python

    lot = 10
    r = np.random.rand(lot * n).astype(np.float32)
    lenr = lot * n
    lenwrk = lot * n
    work = np.zeros(lenwrk, dtype=np.float32)
    ier = _fftpack.rfftmb(lot, 1, n, 1, r, lenr, wsave, lensav, work, lenwrk)


- **Forward Transform**: ``rfftmf``
  - Example:

.. code-block:: python

    r = np.random.rand(lot * n).astype(np.float32)
    ier = _fftpack.rfftmf(lot, 1, n, 1, r, lenr, wsave, lensav, work, lenwrk)

3. Cosine Transforms
::::::::::::::::::::::::::::::

3.1 One-Dimensional Cosine Transform
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Initialization**: ``cost1i``
  - Example:

.. code-block:: python

    n = 16
    lensav = 2 * n + int(np.log(n) / np.log(2)) + 4
    wsave = np.zeros(lensav, dtype=np.float32)
    ier = _fftpack.cost1i(n, wsave)


- **Backward Transform**: ``cost1b``
  - Example:

.. code-block:: python

    x = np.random.rand(1, n).astype(np.float32)
    lenx = n
    lenwrk = n - 1
    work = np.zeros(lenwrk, dtype=np.float32)
    ier = _fftpack.cost1b(n, 1, x, lenx, wsave, lensav, work, lenwrk)


- **Forward Transform**: ``cost1f``
  - Example:

.. code-block:: python

    x = np.random.rand(1, n).astype(np.float32)
    ier = _fftpack.cost1f(n, 1, x, lenx, wsave, lensav, work, lenwrk)

3.2 Multiple Cosine Transform
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Initialization**: ``costmi``
  - Example:

.. code-block:: python

    n = 16
    lensav = 2 * n + int(np.log(n) / np.log(2)) + 4
    wsave = np.zeros(lensav, dtype=np.float32)
    ier = _fftpack.costmi(n, wsave)


- **Backward Transform**: ``costmb``
  - Example:

.. code-block:: python

    lot = 10
    x = np.random.rand(1, lot * n).astype(np.float32)
    lenx = lot * n
    lenwrk = lot * (n + 1)
    work = np.zeros(lenwrk, dtype=np.float32)
    ier = _fftpack.costmb(lot, 1, n, 1, x, lenx, wsave, lensav, work, lenwrk)


- **Forward Transform**: ``costmf``
  - Example:

.. code-block:: python

    x = np.random.rand(1, lot * n).astype(np.float32)
    ier = _fftpack.costmf(lot, 1, n, 1, x, lenx, wsave, lensav, work, lenwrk)

4. Sine Transforms
::::::::::::::::::::::::::::::

4.1 One-Dimensional Sine Transform
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Initialization**: ``sint1i``
  - Example:

.. code-block:: python

    n = 16
    lensav = n // 2 + n + int(np.log(n) / np.log(2)) + 4
    wsave = np.zeros(lensav, dtype=np.float32)
    ier = _fftpack.sint1i(n, wsave)


- **Backward Transform**: ``sint1b``
  - Example:

.. code-block:: python

    x = np.random.rand(1, n).astype(np.float32)
    lenx = n
    lenwrk = 2 * n + 2
    work = np.zeros(lenwrk, dtype=np.float32)
    ier = _fftpack.sint1b(n, 1, x, lenx, wsave, lensav, work, lenwrk)


- **Forward Transform**: ``sint1f``
  - Example:

.. code-block:: python

    x = np.random.rand(1, n).astype(np.float32)
    ier = _fftpack.sint1f(n, 1, x, lenx, wsave, lensav, work, lenwrk)

4.2 Multiple Sine Transform
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Initialization**: ``sintmi``
  - Example:

.. code-block:: python

    n = 16
    lensav = n // 2 + n + int(np.log(n) / np.log(2)) + 4
    wsave = np.zeros(lensav, dtype=np.float32)
    ier = _fftpack.sintmi(n, wsave)


- **Backward Transform**: ``sintmb``
  - Example:

.. code-block:: python

    lot = 10
    x = np.random.rand(1, lot * n).astype(np.float32)
    lenx = lot * n
    lenwrk = lot * (2 * n + 4)
    work = np.zeros(lenwrk, dtype=np.float32)
    ier = _fftpack.sintmb(lot, 1, n, 1, x, lenx, wsave, lensav, work, lenwrk)


- **Forward Transform**: ``sintmf``
  - Example:

.. code-block:: python

    x = np.random.rand(1, lot * n).astype(np.float32)
    ier = _fftpack.sintmf(lot, 1, n, 1, x, lenx, wsave, lensav, work, lenwrk)

5. Quarter-Wave Cosine Transforms
:::::::::::::::::::::::::::::::::::::

5.1 One-Dimensional Quarter-Cosine Transform
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Initialization**: ``cosq1i``
  - Example:

.. code-block:: python

    n = 16
    lensav = 2 * n + int(np.log(n) / np.log(2)) + 4
    wsave = np.zeros(lensav, dtype=np.float32)
    ier = _fftpack.cosq1i(n, wsave)


- **Backward Transform**: ``cosq1b``
  - Example:

.. code-block:: python

    x = np.random.rand(1, n).astype(np.float32)
    lenx = n
    lenwrk = n
    work = np.zeros(lenwrk, dtype=np.float32)
    ier = _fftpack.cosq1b(n, 1, x, lenx, wsave, lensav, work, lenwrk)


- **Forward Transform**: ``cosq1f``
  - Example:

.. code-block:: python

    x = np.random.rand(1, n).astype(np.float32)
    ier = _fftpack.cosq1f(n, 1, x, lenx, wsave, lensav, work, lenwrk)

5.2 Multiple Quarter-Cosine Transform
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Initialization**: ``cosqmi``
  - Example:

.. code-block:: python

    n = 16
    lensav = 2 * n + int(np.log(n) / np.log(2)) + 4
    wsave = np.zeros(lensav, dtype=np.float32)
    ier = _fftpack.cosqmi(n, wsave)


- **Backward Transform**: ``cosqmb``
  - Example:

.. code-block:: python

    lot = 10
    x = np.random.rand(1, lot * n).astype(np.float32)
    lenx = lot * n
    lenwrk = lot * n
    work = np.zeros(lenwrk, dtype=np.float32)
    ier = _fftpack.cosqmb(lot, 1, n, 1, x, lenx, wsave, lensav, work, lenwrk)


- **Forward Transform**: ``cosqmf``
  - Example:

.. code-block:: python

    x = np.random.rand(1, lot * n).astype(np.float32)
    ier = _fftpack.cosqmf(lot, 1, n, 1, x, lenx, wsave, lensav, work, lenwrk)

6. Quarter-Wave Sine Transforms
:::::::::::::::::::::::::::::::::::::

6.1 One-Dimensional Quarter-Sine Transform
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Initialization**: ``sinq1i``
  - Example:

.. code-block:: python

    n = 16
    lensav = 2 * n + int(np.log(n) / np.log(2)) + 4
    wsave = np.zeros(lensav, dtype=np.float32)
    ier = _fftpack.sinq1i(n, wsave)


- **Backward Transform**: ``sinq1b``
  - Example:

.. code-block:: python
    
    x = np.random.rand(1, n).astype(np.float32)
    lenx = n
    lenwrk = n
    work = np.zeros(lenwrk, dtype=np.float32)
    ier = _fftpack.sinq1b(n, 1, x, lenx, wsave, lensav, work, lenwrk)


- **Forward Transform**: ``sinq1f``
  - Example:

.. code-block:: python

    x = np.random.rand(1, n).astype(np.float32)
    ier = _fftpack.sinq1f(n, 1, x, lenx, wsave, lensav, work, lenwrk)

6.2 Multiple Quarter-Sine Transform
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Initialization**: ``sinqmi``
  - Example:

.. code-block:: python

    n = 16
    lensav = 2 * n + int(np.log(n) / np.log(2)) + 4
    wsave = np.zeros(lensav, dtype=np.float32)
    ier = _fftpack.sinqmi(n, wsave)


- **Backward Transform**: ``sinqmb``
  - Example:

.. code-block:: python

    lot = 10
    x = np.random.rand(1, lot * n).astype(np.float32)
    lenx = lot * n
    lenwrk = lot * n
    work = np.zeros(lenwrk, dtype=np.float32)
    ier = _fftpack.sinqmb(lot, 1, n, 1, x, lenx, wsave, lensav, work, lenwrk)


- **Forward Transform**: ``sinqmf``
  - Example:

.. code-block:: python

    x = np.random.rand(1, lot * n).astype(np.float32)
    ier = _fftpack.sinqmf(lot, 1, n, 1, x, lenx, wsave, lensav, work, lenwrk)

Notes and Best Practices
------------------------

- **Work Array (`wsave`)**: Must be initialized using the corresponding `i` subroutine before any transform. Reusable for the same sequence length.
- **Data Types**: Use `np.float32` for real arrays and `np.complex64` for complex arrays to match FFTPACK's single-precision requirements.
- **Error Handling**: Check the `ier` return value; `0` indicates success, while non-zero values signal issues like insufficient array sizes.
- **Performance**: Transforms are most efficient when sequence lengths are products of small primes (e.g., 2, 3, 5).
- **Array Dimensions**: Ensure input arrays match the expected sizes (`lenc`, `lenr`, `lensav`, `lenwrk`) as specified in the examples.
