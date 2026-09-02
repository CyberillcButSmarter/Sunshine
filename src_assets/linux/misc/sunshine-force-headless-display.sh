#!/bin/sh
# Force one DRM connector "connected" so headless KMS capture (used by
# Sunshine's screen-capture backend) has an active display to grab from.
#
# This is a no-op whenever any connector already reports "connected" - a
# real monitor or an HDMI/DP dummy plug always takes priority and nothing
# here overrides it. It only kicks in when the box is genuinely display-less.
#
# Installed by udev (see 99-sunshine-headless-display.rules) and re-run on
# every DRM device add/change event, so it also recovers if the forced
# connector briefly flaps.

set -eu

status_files() {
  for status in /sys/class/drm/card*-*/status; do
    [ -e "$status" ] && printf '%s\n' "$status"
  done
}

# If anything is already connected, there's nothing to do.
for status in $(status_files); do
  if [ "$(cat "$status")" = "connected" ]; then
    exit 0
  fi
done

# Otherwise, force the first non-Writeback connector on.
for status in $(status_files); do
  case "$status" in
    */card*-Writeback-*/status) continue ;;
  esac
  if echo on > "$status" 2>/dev/null; then
    exit 0
  fi
done

exit 1
