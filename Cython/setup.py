from setuptools import Extension, setup
from Cython.Build import cythonize

ext_modules = [
    Extension(
        "rumor",
        ["rumor.pyx"],
        extra_compile_args=["-fopenmp"],
        extra_link_args=["-fopenmp"]
    )
]

setup(
    name="rumor-parallel",
    ext_modules = cythonize(ext_modules, annotate=True)
)