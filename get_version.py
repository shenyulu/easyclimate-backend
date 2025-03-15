# get_version.py
import os
import sys

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import easyclimate_backend

print(easyclimate_backend.__version__)