# PR screenshots

Every UI PR shows the change in EN and RU, from the iOS simulator and the
Android emulator. One command takes them:

```bash
make screenshots                                  # en ru, the four parent tabs, both platforms
make screenshots LANGS="en ru ky kk uz"           # all five, e.g. to check ky/kk overflow
make screenshots SCREENS="today limits"           # just these screens
PLATFORMS=android SKIP_BUILD=1 make screenshots   # rerun without rebuilding
```

Output: `artifacts/screenshots/<branch>/<platform>-<lang>-<screen>.png` plus
`contact-sheet.png`, one grid of the whole run to paste into the PR. The
folder is gitignored.

## What it does

`tool/screenshots/shoot.py`, per platform:

1. boots the device. Android starts its own `-read-only` instance of the AVD,
   so app data is cleared in a throwaway overlay and whatever session the AVD
   holds for other QA is left alone. A simulator it booted is shut down at the
   end, and an already booted one is left running.
2. builds and installs a debug app (`flutter build apk --debug`,
   `flutter build ios --simulator --debug`).
3. signs the demo parent from README.md in (`maestro/login.yaml`).
4. per language: Settings -> Change Language, relaunch, then opens and
   captures each screen.

## Knobs (environment variables)

| Variable | Default | |
| --- | --- | --- |
| `LANGS` | `en ru` | any of `en ru ky uz kk` |
| `SCREENS` | `today tasks limits family` | keys of `SCREENS` in `shoot.py` |
| `PLATFORMS` | `ios android` | |
| `AVD` | `Safini_QA` | never `Pixel_10a`, it is paired to production |
| `IOS_SIM` | `iPhone 17 Pro` | simulator name |
| `DART_DEFINES` | | space separated, e.g. `FINI_DEMO=true FINI_DEMO_STATE=runningPlan` |
| `SKIP_BUILD` | | `1` reuses the last build |
| `KEEP_DEVICES` | | `1` leaves the devices running |
| `SHOW` | | `1` shows the emulator window and Simulator.app |
| `EMAIL` / `PASSWORD` | demo parent | another account to sign in |

## Needs

Xcode, the Android SDK with the AVD, Maestro (`brew install maestro`), and
Pillow for the contact sheet (`pip3 install Pillow`). Maestro needs a JDK; the
script uses Android Studio's bundled JBR when `JAVA_HOME` is unset.

## Adding a screen

Every step finds its element by a Semantics id, never by text or coordinates,
so the flows work in all five languages. To make a new screen capturable:

1. add its id to `lib/core/utils/qa_ids.dart` and put it on the widget:
   `Semantics(identifier: QaIds.navFini, container: true, child: ...)`, or
   `DsTabItem(semanticsId: ...)` for a tab.
2. add a line to `SCREENS` in `tool/screenshots/shoot.py`.

`test/qa_ids_test.dart` fails when a Maestro flow uses an id `QaIds` doesn't
have.

## Fini demo data

The Fini screens need states the demo account doesn't have: an Android child
with usage, a running plan, a pending time request, an expired trial. In a
debug build, `--dart-define=FINI_DEMO=true` swaps the Fini repository for
fixtures, and `FINI_DEMO_STATE` picks one (`lib/features/fini/demo/fini_demo.dart`).
Release and profile builds ignore both.
