pre-commit-install:
	pre-commit install

pre-commit: pre-commit-install
	pre-commit run --all-files
