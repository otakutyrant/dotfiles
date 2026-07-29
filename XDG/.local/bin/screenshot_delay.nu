#!/usr/bin/env nu
let selector_path = ($env.CURRENT_FILE | path dirname | path join screenshot_select.nu)
^$selector_path --delay 5sec
