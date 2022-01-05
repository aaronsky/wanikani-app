format:
	swift format \
		--configuration .swift-format.json \
		--ignore-unparsable-files \
		--in-place \
		--recursive \
		./wanikani-app.swiftpm/Sources ./wanikani-app.swiftpm/Tests

lint:
	swift format lint \
		--configuration .swift-format.json \
		--ignore-unparsable-files \
		--recursive \
		./wanikani-app.swiftpm/Sources ./wanikani-app.swiftpm/Tests

.PHONY: format lint
