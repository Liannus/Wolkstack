from setuptools import setup, find_packages
from io import open
from os import path

import pathlib
# The directory containing this file
HERE = pathlib.Path(__file__).parent  # The text of the README file

README = (HERE / "README.md").read_text()

# automatically captured required modules for install_requires in requirements.txt and as well as configure dependency links
with open(path.join(HERE, 'requirements.txt'), encoding='utf-8') as f:
    all_reqs = f.read().split('\n')

install_requires = [x.strip() for x in all_reqs if ('git+' not in x)
                    and (
    not x.startswith('#')) and (not x.startswith('-'))]

dependency_links = [x.strip().replace('git+', '') for x in all_reqs
                    if 'git+' not in x]

setup(
    name='Wolkstack',
    description='A Framework for blazing fast cloud infrastructure management and deployment',
    packages=find_packages(),
    version='1.1.1',
    install_requires=install_requires,
    python_requires='>=3.7',
    entry_points='''
        [console_scripts]
        wolkstack=wolkstack.cli.main:main
    ''',
    author='Josh Gorman',
    keyword='infrastructure, deployment, aws, wolkstack, cloud',
    long_description=README,
    long_description_content_type='text/markdown',
    license='MIT',
    url="https://github.com/liannus/wolkstack",
    dependency_links=dependency_links,
    author_email='josh-gorman@hotmail.com',
    classifiers=[
        "License :: OSI Approved :: MIT License",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.7",
    ]
)
