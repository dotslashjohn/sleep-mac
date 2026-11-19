# sleep-mac

Source for SleepToggle, a tiny native menu bar app (no dependencies) that toggles macOS sleep via `pmset disablesleep`.
The built app lives at `~/Applications/SleepToggle.app`; this folder is just the code.

- 🌙 `moon.zzz` icon: sleep is normal. Click to keep the Mac awake.
- ☕ `cup.and.saucer.fill` icon: sleep is disabled (stays awake, even lid closed). Click to allow sleep.
- Right-click (or ctrl-click): menu with Quit.
- Polls the real setting every 10s, so it stays in sync with the terminal scripts.

## Install / rebuild

Requires Xcode Command Line Tools (`xcode-select --install`) for `swiftc`.

```sh
./install.sh
```

Builds `~/Applications/SleepToggle.app` from `main.swift`, ad-hoc signs it, and launches it. Re-run after editing `main.swift`.

### Optional: no password prompt on toggle

Without this, each click shows an admin password dialog. This sudoers rule allows only these two exact commands:

```sh
echo "$USER ALL=(root) NOPASSWD: /usr/bin/pmset -a disablesleep 0, /usr/bin/pmset -a disablesleep 1" \
  | sudo tee /etc/sudoers.d/sleeptoggle >/dev/null \
  && sudo chmod 440 /etc/sudoers.d/sleeptoggle \
  && sudo visudo -cf /etc/sudoers.d/sleeptoggle
```

### Start at login

System Settings → General → Login Items → **+** → `~/Applications/SleepToggle.app`.

## Terminal equivalents

In `~/.local/bin` (on PATH):

- `turn_sleep_off.sh` → `sudo pmset -a disablesleep 1` (stay awake)
- `turn_sleep_back_on.sh` → `sudo pmset -a disablesleep 0` (normal sleep)

Check state: `pmset -g | grep -i sleepdisabled` (`1` = sleep off).

## Uninstall

```sh
pkill -x SleepToggle; rm -rf ~/Applications/SleepToggle.app; sudo rm -f /etc/sudoers.d/sleeptoggle
```
