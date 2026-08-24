.PHONY: help increment-build build-ios build-android build clean icons generate get openapi

# Default target: list commands
help:
	@echo "Safini Makefile commands:"
	@echo "  make get             - Fetch dependencies (flutter pub get)"
	@echo "  make increment-build - Bump build number in pubspec.yaml (1.0.0+N -> 1.0.0+N+1)"
	@echo "  make generate        - Run codegen (intl + build_runner: freezed/json_serializable)"
	@echo "  make openapi         - Refresh lib/api_reference/api.json from production"
	@echo "  make icons           - Generate app launcher icons (flutter_launcher_icons)"
	@echo "  make build-ios       - Increment build, then build iOS release IPA"
	@echo "  make build-android   - Increment build, then build Android App Bundle (.aab) + APK"
	@echo "  make build           - Increment build, then build both iOS and Android"
	@echo "  make clean           - Clean build artifacts and re-fetch dependencies"

# Fetch dependencies
get:
	flutter pub get

# Increment the build number (the +N suffix) in pubspec.yaml
increment-build:
	@current=$$(grep '^version:' pubspec.yaml | sed 's/version: *//'); \
	name=$${current%+*}; \
	build=$${current#*+}; \
	newbuild=$$((build + 1)); \
	sed -i '' "s/^version: .*/version: $$name+$$newbuild/" pubspec.yaml; \
	echo "Build number: $$build -> $$newbuild (version $$name+$$newbuild)"

# Generate localization + freezed/json_serializable sources
generate:
	flutter pub run intl_utils:generate
	flutter pub run build_runner build --delete-conflicting-outputs

# Refresh the vendored OpenAPI spec. CI fails when it and api.safini.fun
# describe different routes, and the indentation has to match or the diff is
# the whole file.
openapi:
	@curl -fsS --max-time 30 https://api.safini.fun/openapi.json \
	| python3 -c "import json, sys; json.dump(json.load(sys.stdin), sys.stdout, indent=2, ensure_ascii=False); print()" \
	> lib/api_reference/api.json
	@echo "lib/api_reference/api.json refreshed from api.safini.fun"

# Generate app launcher icons
icons:
	flutter pub run flutter_launcher_icons

# Build iOS release IPA (bumps build number first)
build-ios: increment-build
	flutter build ipa --release

# Build Android App Bundle + APK (bumps build number first)
build-android: increment-build
	flutter build appbundle --release
	flutter build apk --release

# Build both platforms
build: build-ios build-android

# Clean build artifacts then re-fetch dependencies
clean:
	flutter clean
	flutter pub get
