#!/usr/bin/env python3
"""EN/RU (or any) screenshots of the parent app from the iOS simulator and the
Android emulator, for PR descriptions.

    make screenshots LANGS="en ru" SCREENS="today tasks limits family"

Writes artifacts/screenshots/<branch>/<platform>-<lang>-<screen>.png plus
contact-sheet.png. See commands/screenshots.md for the knobs.

Navigation is Maestro on both platforms, by Semantics id (lib/core/utils/
qa_ids.dart), so no step depends on screen coordinates or on the app language.
"""

from __future__ import annotations

import json
import os
import re
import shutil
import subprocess
import sys
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
FLOWS = Path(__file__).resolve().parent / "maestro"
APP_ID = "com.safini.app"

# Screen name -> the Semantics id that opens it from the parent tab bar.
# A new screen (the Fini tab, Fini onboarding) adds one line here.
# Each screen is the Semantics ids to tap, in order, comma separated.
SCREENS = {
    "today": "nav.today",
    "tasks": "nav.tasks",
    "limits": "nav.limits",
    "family": "nav.family",
    "today-everyone": "nav.today,kid.everyone",
    "limits-everyone": "nav.limits,kid.everyone",
}
LANGS = ("en", "ru", "ky", "uz", "kk")

# Demo parent from README.md. Override with EMAIL / PASSWORD.
DEMO_EMAIL = "safini.team@gmail.com"
DEMO_PASSWORD = "stopscrolling"

ANDROID_SDK = Path(
    os.environ.get("ANDROID_HOME", Path.home() / "Library/Android/sdk")
)
STUDIO_JBR = Path("/Applications/Android Studio.app/Contents/jbr/Contents/Home")
# Out of the 5554-5584 range a manually started emulator takes first.
EMULATOR_PORT = 5580


def log(msg: str) -> None:
    print(f"[screenshots] {msg}", flush=True)


def run(cmd: list[str], **kw) -> subprocess.CompletedProcess:
    return subprocess.run(cmd, check=True, **kw)


def out(cmd: list[str]) -> str:
    return subprocess.run(cmd, check=True, capture_output=True, text=True).stdout


def words(name: str, default: str) -> list[str]:
    return os.environ.get(name, default).split()


# --- devices -------------------------------------------------------------


class Android:
    name = "android"

    def __init__(self, avd: str):
        self.avd = avd
        self.adb = str(ANDROID_SDK / "platform-tools/adb")
        self.serial = f"emulator-{EMULATOR_PORT}"
        self.started = False

    def boot(self) -> None:
        # Always our own instance, -read-only: every write goes to a temp
        # overlay dropped on exit. The AVD may hold someone's child session
        # for other QA; this run clears app data freely and leaves it intact.
        # It also runs next to an already open instance of the same AVD.
        # -no-snapshot-load: a quickboot snapshot can restore a dead session.
        cmd = [
            str(ANDROID_SDK / "emulator/emulator"),
            "-avd", self.avd,
            "-port", str(EMULATOR_PORT),
            "-read-only",
            "-no-snapshot-load",
            "-no-snapshot-save",
            "-no-boot-anim",
        ]
        if os.environ.get("SHOW") != "1":
            cmd.append("-no-window")
        log(f"android: booting {self.avd}")
        subprocess.Popen(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        self.started = True
        run([self.adb, "-s", self.serial, "wait-for-device"])
        for _ in range(180):
            prop = subprocess.run(
                [self.adb, "-s", self.serial, "shell", "getprop", "sys.boot_completed"],
                capture_output=True,
                text=True,
            ).stdout.strip()
            if prop == "1":
                return
            time.sleep(2)
        sys.exit(f"{self.avd} did not finish booting in 6 minutes")

    def build(self, defines: list[str]) -> None:
        run(["flutter", "build", "apk", "--debug", *defines], cwd=ROOT)

    def install(self) -> None:
        apk = ROOT / "build/app/outputs/flutter-apk/app-debug.apk"
        # The overlay is thrown away anyway, so start the app clean and
        # login.yaml always signs the demo parent in. `pm clear`, not
        # uninstall: a paired child app is a device admin and can't be removed.
        # -d lets the debug build replace a store build's higher version code.
        adb = [self.adb, "-s", self.serial]
        run([*adb, "install", "-r", "-d", str(apk)], stdout=subprocess.DEVNULL)
        run([*adb, "shell", "pm", "clear", APP_ID], stdout=subprocess.DEVNULL)

    def screenshot(self, path: Path) -> None:
        png = subprocess.run(
            [self.adb, "-s", self.serial, "exec-out", "screencap", "-p"],
            check=True,
            capture_output=True,
        ).stdout
        path.write_bytes(png)

    def shutdown(self) -> None:
        if self.started:
            subprocess.run([self.adb, "-s", self.serial, "emu", "kill"],
                           capture_output=True)


class Ios:
    name = "ios"

    def __init__(self, device_name: str):
        devices = json.loads(out(["xcrun", "simctl", "list", "devices", "-j"]))
        match = [
            d
            for runtime, ds in devices["devices"].items()
            if "iOS" in runtime
            for d in ds
            if d["name"] == device_name and d.get("isAvailable", True)
        ]
        if not match:
            sys.exit(f'no available iOS simulator named "{device_name}"')
        self.udid = match[-1]["udid"]
        self.serial = self.udid
        self.started = match[-1]["state"] != "Booted"

    def boot(self) -> None:
        if self.started:
            log("ios: booting simulator")
            run(["xcrun", "simctl", "boot", self.udid])
        run(["xcrun", "simctl", "bootstatus", self.udid, "-b"],
            stdout=subprocess.DEVNULL)
        if os.environ.get("SHOW") == "1":
            subprocess.run(["open", "-a", "Simulator"])

    def build(self, defines: list[str]) -> None:
        run(["flutter", "build", "ios", "--simulator", "--debug", *defines],
            cwd=ROOT)

    def install(self) -> None:
        app = ROOT / "build/ios/iphonesimulator/Runner.app"
        run(["xcrun", "simctl", "install", self.udid, str(app)])

    def screenshot(self, path: Path) -> None:
        run(["xcrun", "simctl", "io", self.udid, "screenshot", str(path)],
            capture_output=True)

    def shutdown(self) -> None:
        if self.started:
            subprocess.run(["xcrun", "simctl", "shutdown", self.udid],
                           capture_output=True)


# --- maestro -------------------------------------------------------------


def maestro(device, flow: str, **env: str) -> None:
    cmd = ["maestro", "--device", device.serial, "test"]
    for key, value in env.items():
        cmd += ["-e", f"{key}={value}"]
    cmd.append(str(FLOWS / flow))
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        print(result.stdout[-3000:], result.stderr[-2000:], sep="\n")
        raise RuntimeError(f"{device.name}: maestro {flow} {env} failed")


# --- contact sheet ---------------------------------------------------------


def contact_sheet(shots: list[Path], dest: Path, screens: list[str]) -> None:
    try:
        from PIL import Image, ImageDraw, ImageFont
    except ImportError:
        log("Pillow is missing (pip3 install Pillow), skipping contact-sheet.png")
        return

    # One row per platform + language, one column per screen.
    rows: dict[str, dict[str, Path]] = {}
    for shot in shots:
        platform, lang, screen = shot.stem.split("-", 2)
        rows.setdefault(f"{platform} {lang}", {})[screen] = shot

    cell_w, label_h, gap = 300, 34, 12
    cells = {}
    cell_h = 0
    for row in rows.values():
        for screen, path in row.items():
            img = Image.open(path).convert("RGB")
            img = img.resize((cell_w, round(img.height * cell_w / img.width)))
            cells[path] = img
            cell_h = max(cell_h, img.height)

    width = gap + len(screens) * (cell_w + gap)
    height = gap + len(rows) * (label_h + cell_h + gap)
    sheet = Image.new("RGB", (width, height), "white")
    draw = ImageDraw.Draw(sheet)
    try:
        font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 20)
    except OSError:
        font = ImageFont.load_default()

    y = gap
    for title, row in rows.items():
        for col, screen in enumerate(screens):
            x = gap + col * (cell_w + gap)
            draw.text((x, y + 6), f"{title} · {screen}", fill="black", font=font)
            if screen in row:
                sheet.paste(cells[row[screen]], (x, y + label_h))
        y += label_h + cell_h + gap
    sheet.save(dest)
    log(f"contact sheet: {dest.relative_to(ROOT)}")


# --- main ------------------------------------------------------------------


def branch_dir() -> Path:
    branch = out(["git", "-C", str(ROOT), "rev-parse", "--abbrev-ref", "HEAD"]).strip()
    return ROOT / "artifacts/screenshots" / re.sub(r"[^\w.-]+", "-", branch)


def main() -> None:
    langs = words("LANGS", "en ru")
    screens = words("SCREENS", "today tasks limits family")
    platforms = words("PLATFORMS", "ios android")
    defines = [f"--dart-define={d}" for d in words("DART_DEFINES", "")]
    for lang in langs:
        if lang not in LANGS:
            sys.exit(f"unknown language {lang!r}, expected one of {LANGS}")
    for screen in screens:
        if screen not in SCREENS:
            sys.exit(f"unknown screen {screen!r}, add it to SCREENS in {__file__}")

    if not os.environ.get("JAVA_HOME") and STUDIO_JBR.exists():
        os.environ["JAVA_HOME"] = str(STUDIO_JBR)
        os.environ["PATH"] = f"{STUDIO_JBR}/bin:{os.environ['PATH']}"
    if not shutil.which("maestro"):
        sys.exit("maestro not found: curl -Ls https://get.maestro.mobile.dev | bash")

    dest = branch_dir()
    dest.mkdir(parents=True, exist_ok=True)
    creds = {
        "EMAIL": os.environ.get("EMAIL", DEMO_EMAIL),
        "PASSWORD": os.environ.get("PASSWORD", DEMO_PASSWORD),
    }

    devices = []
    for p in platforms:
        if p == "android":
            devices.append(Android(os.environ.get("AVD", "Safini_QA")))
        elif p == "ios":
            devices.append(Ios(os.environ.get("IOS_SIM", "iPhone 17 Pro")))
        else:
            sys.exit(f"unknown platform {p!r}, expected ios and/or android")

    shots: list[Path] = []
    failed = False
    try:
        for device in devices:
            device.boot()
            if os.environ.get("SKIP_BUILD") != "1":
                log(f"{device.name}: building debug app")
                device.build(defines)
            device.install()
            log(f"{device.name}: signing in")
            maestro(device, "login.yaml", **creds)
            for lang in langs:
                try:
                    maestro(device, "set_language.yaml", LANG=lang)
                    for screen in screens:
                        for nav in SCREENS[screen].split(","):
                            maestro(device, "open_screen.yaml", NAV=nav)
                        shot = dest / f"{device.name}-{lang}-{screen}.png"
                        device.screenshot(shot)
                        shots.append(shot)
                        log(f"saved {shot.relative_to(ROOT)}")
                except RuntimeError as e:
                    # One language failing shouldn't throw away the rest.
                    log(str(e))
                    failed = True
    finally:
        if os.environ.get("KEEP_DEVICES") != "1":
            for device in devices:
                device.shutdown()

    if shots:
        contact_sheet(shots, dest / "contact-sheet.png", screens)
    if failed:
        sys.exit(1)


if __name__ == "__main__":
    main()
