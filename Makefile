.PHONY: help version version-check bump-build bump-patch bump-minor increment-build \
	build-ios build-android build clean icons generate get openapi

PYTHON ?= python3
VERSION_PY := $(PYTHON) scripts/pubspec_version.py

# Default target: list commands
help:
	@echo "Safini Makefile commands:"
	@echo "  make get             - Fetch dependencies (flutter pub get)"
	@echo "  make version         - Show store version + bump rules (pubspec.yaml)"
	@echo "  make version-check   - Fail if version is behind origin/main or mixed in a PR"
	@echo "  make bump-build      - +N+1; every Play / TestFlight upload. Main only."
	@echo "  make bump-patch      - 1.0.9+N -> 1.0.10+N+1 (fixes). Main only."
	@echo "  make bump-minor      - 1.0.9+N -> 1.1.0+N+1 (features). Main only."
	@echo "  make generate        - Run codegen (intl + build_runner: freezed/json_serializable)"
	@echo "  make openapi         - Refresh lib/api_reference/api.json from production"
	@echo "  make icons           - Generate app launcher icons (flutter_launcher_icons)"
	@echo "  make build-ios       - bump-build, then build iOS release IPA"
	@echo "  make build-android   - bump-build, then build Android App Bundle (.aab) + APK"
	@echo "  make build           - bump-build once, then build iOS and Android"
	@echo "  make clean           - Clean build artifacts and re-fetch dependencies"
	@echo ""
	@echo "Version bumps refuse feature branches and a stale main (git pull first)."
	@echo "Override only for a known store upload: FORCE=1 make bump-build"

# Fetch dependencies
get:
	flutter pub get

version:
	@$(VERSION_PY) show

# CI and pre-PR: VERSION_CHECK_PR=1 also rejects mixing a bump with other files.
version-check:
	@$(VERSION_PY) check $(if $(filter 1,$(VERSION_CHECK_PR)),--pr,)

# Increment the build number (the +N suffix) in pubspec.yaml
bump-build increment-build:
	@$(VERSION_PY) bump build $(if $(filter 1,$(FORCE)),--force,)

bump-patch:
	@$(VERSION_PY) bump patch $(if $(filter 1,$(FORCE)),--force,)

bump-minor:
	@$(VERSION_PY) bump minor $(if $(filter 1,$(FORCE)),--force,)

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
build-ios: bump-build
	flutter build ipa --release

# Build Android App Bundle + APK (bumps build number first)
build-android: bump-build
	flutter build appbundle --release
	flutter build apk --release

# Build both platforms (one bump, then both artifacts)
build: bump-build
	flutter build ipa --release
	flutter build appbundle --release
	flutter build apk --release

# Clean build artifacts then re-fetch dependencies
clean:
	flutter clean
	flutter pub get
