#!/usr/bin/env bash
# Tunathic - Google Play raw screenshot capture.
#
# Drives the installed Tunathic build on a running Android emulator through the
# real UI and writes untouched `adb exec-out screencap` PNGs. No image editing
# happens here; marketing composition is compose_screenshots.py.
#
# Every tap coordinate is raw device pixels and therefore device-specific, so
# they live in design/store/profiles/<profile>.env rather than in this script.
# Re-read them off a fresh capture after any layout change.
#
# Usage: design/store/capture_device.sh <adb-serial> <output-dir> <profile>
#   profile: phone | tablet7 | tablet10
set -euo pipefail

ADB="${ADB:-$HOME/AppData/Local/Android/Sdk/platform-tools/adb.exe}"
SERIAL="$1"
OUT="$2"
PROFILE="$3"
PKG=dev.gundev.tunathic
HERE="$(cd "$(dirname "$0")" && pwd)"

# shellcheck source=/dev/null
source "$HERE/profiles/$PROFILE.env"

mkdir -p "$OUT"

a() { "$ADB" -s "$SERIAL" "$@"; }
tap() { a shell input tap "$1" "$2"; sleep "${3:-2}"; }
shot() { a exec-out screencap -p > "$OUT/$1.png"; echo "  captured $1"; }
page_down() { a shell input swipe "$SWIPE_X" "$SWIPE_FROM_Y" "$SWIPE_X" "$SWIPE_TO_Y" 400; sleep 1; }

relaunch() {
  a shell am force-stop "$PKG"
  sleep 1
  a shell am start -n "$PKG/.MainActivity" > /dev/null
  sleep "$LAUNCH_WAIT"
}

# ---- one-time device prep -------------------------------------------------
# Animations off, screen kept awake, microphone already granted (so the runtime
# permission dialog never lands in a capture), and a fixed clean status bar.
a shell settings put global window_animation_scale 0
a shell settings put global transition_animation_scale 0
a shell settings put global animator_duration_scale 0
a shell svc power stayon true
a shell pm grant "$PKG" android.permission.RECORD_AUDIO || true

# Some tablet AVDs are natively landscape; the store set is portrait, so the
# profile names the rotation that gets this device there (0=natural, 1=90 deg).
if [ -n "${USER_ROTATION:-}" ]; then
  a shell settings put system accelerometer_rotation 0
  a shell settings put system user_rotation "$USER_ROTATION"
  sleep 3
fi

a shell settings put global sysui_demo_allowed 1
demo() { a shell am broadcast -a com.android.systemui.demo "$@" > /dev/null; }
demo -e command enter
demo -e command clock -e hhmm 0930
demo -e command battery -e level 100 -e plugged false
demo -e command network -e wifi show -e level 4
demo -e command network -e mobile hide
demo -e command notifications -e visible false
demo -e command status -e volume hide -e bluetooth hide -e location hide \
     -e alarm hide -e sync hide -e tty hide -e eri hide -e mute hide -e speakerphone hide

echo "01 dashboard / guitar toolkit"
relaunch
shot 01_toolkit

echo "02 guitar tuner, automatic, standard tuning"
relaunch
tap "$DASH_TUNER_X" "$DASH_TUNER_Y" 5
shot 02_tuner

echo "04 guitar tuner, manual, low E selected"
tap "$TUNER_MANUAL_X" "$TUNER_MODE_Y" 3
shot 04_tuner_manual
tap "$TUNER_AUTOMATIC_X" "$TUNER_MODE_Y" 2

echo "06 tuning settings: tuning system + reference pitch"
tap "$TUNER_SETTINGS_X" "$TUNER_SETTINGS_Y" 4
shot 06_tuning_settings

echo "03 guitar tuner, chromatic"
tap "$TS_X" "$TS_CHROMATIC_Y" 2
tap "$BACK_X" "$BACK_Y" 4
shot 03_tuner_chromatic
# Put the preset back so the next run starts from Standard.
tap "$TUNER_SETTINGS_X" "$TUNER_SETTINGS_Y" 3
tap "$TS_X" "$TS_STANDARD_Y" 2
tap "$BACK_X" "$BACK_Y" 2

echo "05 metronome running, 120 BPM, 4/4, accent on, beat 1"
relaunch
tap "$DASH_METRONOME_X" "$DASH_METRONOME_Y" 4
tap "$METRO_BPM_X" "$METRO_BPM_Y" 2
a shell input keyevent KEYCODE_MOVE_END
for _ in 1 2 3 4 5; do a shell input keyevent KEYCODE_DEL; done
a shell input text "120"
a shell input keyevent KEYCODE_ENTER
sleep 2
tap "$METRO_STARTSTOP_X" "$METRO_STARTSTOP_Y" 3
# At 120 BPM the accented first beat is lit for 500 ms in every 2 s. Grab a
# short burst and keep the frame whose first lamp is on; pick_beat_one.py does
# the choosing, so no capture is ever edited to fake it.
for i in 1 2 3 4 5 6 7 8; do
  a exec-out screencap -p > "$OUT/.metronome_$i.png"
done
tap "$METRO_STARTSTOP_X" "$METRO_STARTSTOP_Y" 1
python "$HERE/pick_beat_one.py" "$OUT" 05_metronome --lamps "$LAMP_X" --y "$LAMP_Y"
echo "  captured 05_metronome"

echo "07 chord library"
relaunch
for _ in $(seq 1 "$DASH_SCROLLS"); do page_down; done
sleep 1
tap "$DASH_CHORD_X" "$DASH_CHORD_Y" 5
shot 07_chord_library

echo "08 music theory hub"
relaunch
for _ in $(seq 1 "$DASH_SCROLLS"); do page_down; done
sleep 1
tap "$DASH_THEORY_X" "$DASH_THEORY_Y" 5
shot 08_music_theory

a shell am force-stop "$PKG"
echo "done -> $OUT"
