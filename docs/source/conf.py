# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

import time
import os
import sys
# get year
localtime = time.localtime(time.time())
str_year = str(localtime[0])

# autodoc required
sys.path.insert(
    0, os.path.abspath("../../")
)  # Source code dir relative to this file
import easyclimate_backend

# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information

project = 'Easyclimate-backend'
copyright = f'2022-{str_year}, Easyclimate contributors'
author = 'shenyulu'
release = "v" + easyclimate_backend.__version__

# -- General configuration ---------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#general-configuration

extensions = ['sphinx_wagtail_theme']

templates_path = ['_templates']
exclude_patterns = []

html_last_updated_fmt = "%b %d, %Y"
html_show_sphinx = False

# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

html_theme = 'sphinx-wagtail-theme'
html_static_path = ['_static']

# 

# Add any relative paths that contain templates.
templates_path = ["_templates"]

# Custom sidebar templates, must be a dictionary that maps document names
# to template names. "**" will apply the templates to all pages.
# The theme default is just searchbox and globaltoc.
html_sidebars = {"**": [
    "searchbox.html",
    "globaltoc.html",
    # "custom.html",    # Your template here
]}
# 

try:
   extensions
except NameError:
   extensions = []

extensions.append('sphinx_wagtail_theme')
html_theme = 'sphinx_wagtail_theme'

# These are options specifically for the Wagtail Theme.
html_theme_options = dict(
    project_name = "The backend of Easyclimate",
    logo = "easyclimate_backend_logo_mini.png",
    logo_width = 50,
    logo_alt = "ecl_logo",
    header_links = "Easyclimate docs|https://easyclimate.readthedocs.io/, Easyclimate repository|https://github.com/shenyulu/easyclimate, Easyclimate-backend repository|https://github.com/shenyulu/easyclimate-backend",
    footer_links = ",".join([
        "PyPI (easyclimate)|https://pypi.org/project/easyclimate/",
        "PyPI (easyclimate-backend)|https://pypi.org/project/easyclimate-backend/",
    ]),
    github_url = "https://github.com/shenyulu/easyclimate-backend/blob/main/docs/",
)