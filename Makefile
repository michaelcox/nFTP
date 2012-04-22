DOCS = docs/*.md
HTMLDOCS = $(DOCS:.md=.html)
REPORTER = spec

test:
	@NODE_ENV=test ./node_modules/.bin/mocha \
		--reporter $(REPORTER) \


.PHONY: test