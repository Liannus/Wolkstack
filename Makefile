# Reinstall the package locally
up:
	pip3 install -e .

# Create package distribution and upload to PyPi
upload:
	python setup.py sdist bdist_wheel
	twine upload dist/*whl dist/*gz 

