HARP=./node_modules/harp/bin/harp
SOURCE=source
OUTPUT=build

default: setup compile

setup:
	@./scripts/setup-environment-dev.sh

server:
	@$(HARP) server $(SOURCE)

compile:
	@$(HARP) compile $(SOURCE) $(OUTPUT)
	@echo ""
	@echo "REMINDER: make sure the API version is up-to-date (see scripts/update-api-version.bash)"
	@echo ""
