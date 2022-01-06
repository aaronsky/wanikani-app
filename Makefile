SWIFT_FORMAT_BIN := swift format
GIT_REPO_TOPLEVEL := $(shell git rev-parse --show-toplevel)
SWIFT_FORMAT_CONFIG_FILE := $(GIT_REPO_TOPLEVEL)/.swift-format.json
DERIVED_DATA_PATH := $(GIT_REPO_TOPLEVEL)/DerivedData
SWIFTPM_APP_PROJECT := $(GIT_REPO_TOPLEVEL)/wanikani-app.swiftpm
SOURCES := $(SWIFTPM_APP_PROJECT)/Sources
TESTS := $(SWIFTPM_APP_PROJECT)/Tests

format:
	$(SWIFT_FORMAT_BIN) \
		--configuration $(SWIFT_FORMAT_CONFIG_FILE) \
		--ignore-unparsable-files \
		--in-place \
		--recursive \
		$(SOURCES) $(TESTS)

lint:
	$(SWIFT_FORMAT_BIN) lint \
		--configuration $(SWIFT_FORMAT_CONFIG_FILE) \
		--ignore-unparsable-files \
		--recursive \
		$(SOURCES) $(TESTS)

.PHONY: format lint
