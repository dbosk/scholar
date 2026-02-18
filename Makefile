SUBDIR+=		src/scholar
SUBDIR+=		doc
SUBDIR+=		tests

SUBDIR_GOALS+=	all clean distclean test

INCLUDE_MAKEFILES=makefiles
include ${INCLUDE_MAKEFILES}/subdir.mk

# Extract version from pyproject.toml
version = $(shell sed -n 's/^version *= *"\([^"]*\)"/\1/p' pyproject.toml)

# Publishing targets
.PHONY: publish publish-pypi publish-github doc/scholar.pdf

publish:
	${MAKE} all
	${MAKE} -C tests test
	${MAKE} publish-pypi publish-github

publish-pypi:
	uv build
	uv publish

publish-github: doc/scholar.pdf
	git push
	gh release create -t v${version} v${version} doc/scholar.pdf

# Always delegate to sub-make for freshness check
doc/scholar.pdf:
	${MAKE} -C doc scholar.pdf
