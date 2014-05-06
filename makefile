HARP=./node_modules/harp/bin/harp
SOURCE=source
OUTPUT=build

TYPES_BASE_URL=https://raw.github.com/pryv/data-types/master/
EVENT_TYPES_URL=$(TYPES_BASE_URL)event-types.json
EVENT_EXTRAS_URL=$(TYPES_BASE_URL)event-extras.json

RETRIEVE_EVENT_TYPES=curl -L -o ./source/event-types/hierarchical.json $(EVENT_TYPES_URL)
RETRIEVE_EVENT_EXTRAS=curl -L -o ./source/event-types/extras.json $(EVENT_EXTRAS_URL)

default: setup retrieve-types compile

setup:
	@./scripts/setup-environment-dev.sh

retrieve-types:
	@echo ""
	@echo "Retrieving data types from $(TYPES_BASE_URL)..."
	@echo ""
	@$(RETRIEVE_EVENT_TYPES); $(RETRIEVE_EVENT_EXTRAS)

server:
	@$(HARP) server $(SOURCE)

compile: retrieve-types
	@$(HARP) compile $(SOURCE) $(OUTPUT)

publish: compile
	@cd build;git add .;git add -u .;git commit -m "Updated generated files";git push
