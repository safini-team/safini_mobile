## Summary

-

## Version

Do **not** change `pubspec.yaml` `version:` in a feature or fix PR.

Store version lives in one place and is bumped only on an up-to-date `main`:

- `make version` — current number and the rules
- `make bump-build` — every Play / TestFlight upload (`+N` must go up)
- `make bump-patch` / `make bump-minor` — user-visible `X.Y.Z`

CI fails the PR if a version bump is mixed with other files, if `+N` goes
backwards, or if the marketing version is older than `origin/main`.
