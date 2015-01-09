TYPES_BASE_URL=https://raw.github.com/pryv/data-types/master/
EVENT_TYPES_URL=$(TYPES_BASE_URL)event-types.json
EVENT_EXTRAS_URL=$(TYPES_BASE_URL)event-extras.json
TYPES_SOURCE_TARGET=./source/event-types/_source

build:
	node build.js

watch:
	node build.js watch

clean:
	rm -rf build/*

setup:
	./dev-env/setup.sh

retrieve-types:
	@echo ""
	@echo "Retrieving data types from $(TYPES_BASE_URL)..."
	@echo ""
	@cd $(TYPES_SOURCE_TARGET) && curl -LO $(EVENT_TYPES_URL) -LO $(EVENT_EXTRAS_URL)

publish: retrieve-types build
	@cd build && git add . && git add -u . && git commit -m "Updated generated files" && git push

.PHONY: build
