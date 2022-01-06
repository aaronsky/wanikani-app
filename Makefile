GIT_REPO_TOPLEVEL := $(shell git rev-parse --show-toplevel)
SWIFT_FORMAT_CONFIG_FILE := $(GIT_REPO_TOPLEVEL)/.swift-format.json
DERIVED_DATA_PATH := $(GIT_REPO_TOPLEVEL)/DerivedData
SWIFTPM_APP_PROJECT := $(GIT_REPO_TOPLEVEL)/wanikani-app.swiftpm
SOURCES := $(SWIFTPM_APP_PROJECT)/Sources
TESTS := $(SWIFTPM_APP_PROJECT)/Tests

format:
	swift format \
		--configuration $(SWIFT_FORMAT_CONFIG_FILE) \
		--ignore-unparsable-files \
		--in-place \
		--recursive \
		$(SOURCES) $(TESTS)

lint:
	swift format lint \
		--configuration $(SWIFT_FORMAT_CONFIG_FILE) \
		--ignore-unparsable-files \
		--recursive \
		$(SOURCES) $(TESTS)

build_ci:
	mkdir -p $(DERIVED_DATA_PATH)
	cd $(SWIFTPM_APP_PROJECT)
	xcodebuild \
		-scheme WaniKaniApp \
		-configuration Debug \
		-destination 'platform=iOS Simulator,OS=latest,name=iPhone 13 Pro' \
		-derivedDataPath $(DERIVED_DATA_PATH) \
		-quiet \
		build
	cd -

.PHONY: format lint build_ci
