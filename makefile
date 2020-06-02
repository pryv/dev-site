TYPES_BASE_URL=https://raw.github.com/pryv/data-types/master/dist/
EVENT_TYPES_URL=$(TYPES_BASE_URL)event-types.json
FLAT_TYPES_URL=$(TYPES_BASE_URL)flat.json
TYPES_SOURCE_TARGET=./source/event-types/_source

build:
	node --harmony build.js

watch:
	node --harmony build.js watch

clean:
	rm -rf build/*

setup:
	./dev-env/setup.sh $(core)

retrieve-types:
	@echo ""
	@echo "Retrieving data types from $(TYPES_BASE_URL)..."
	@echo ""
	@cd $(TYPES_SOURCE_TARGET) && curl -LO $(EVENT_TYPES_URL) -LO $(FLAT_TYPES_URL)

retrieve-tests:
	@echo ""
	@echo "Retrieving tests types from git@github.com:pryv/test-results-pryv.io.git..."
	@echo ""
	@cd dependencies/test-results && git pull

publish: retrieve-types retrieve-tests build
	@cd build && git add . && git add -u . && git commit -m "Updated generated files" && git push

.PHONY: build
