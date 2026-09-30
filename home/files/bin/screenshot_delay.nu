#!/usr/bin/env nu

# Delay before selecting a Wayland screenshot region.
^($env.HOME | path join .local/bin/screenshot_select.nu) --delay 5sec
