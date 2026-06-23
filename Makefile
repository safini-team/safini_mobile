.PHONY: help increment-build build-ios build-android build clean icons generate get

# Default target: list commands
help:
	@echo "Safini Makefile commands:"
	@echo "  make get             - Fetch dependencies (flutter pub get)"
	@echo "  make increment-build - Bump build number in pubspec.yaml (1.0.0+N -> 1.0.0+N+1)"
	@echo "  make generate        - Run codegen (intl + build_runner: freezed/json_serializable)"
	@echo "  make icons           - Generate app launcher icons (flutter_launcher_icons)"
	@echo "  make build-ios       - Increment build, then build iOS release (no codesign)"
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

# Generate app launcher icons
icons:
	flutter pub run flutter_launcher_icons

# Build iOS release (bumps build number first)
build-ios: increment-build
	flutter build ios --release --no-codesign

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
