# Image Resize Daemon

This daemon watches only the top level of `/home/otakutyrant` and resizes supported image files in place when their shortest side is less than `800px`.

Supported formats:

- JPEG
- PNG
- WebP
- BMP
- TIFF

Notes:

- Aspect ratio is preserved.
- Images whose shortest side is already greater than or equal to `800px` are left untouched.
- Animated images are skipped.
- Subdirectories are ignored completely; the scan is not recursive.
- Only files whose names start with `202` are considered.

Run one scan:

```bash
python3 /home/otakutyrant/.local/bin/image_resize_daemon.py --once
```

Run continuously:

```bash
python3 /home/otakutyrant/.local/bin/image_resize_daemon.py
```

Install as a user service:

```bash
stow Systemd
systemctl --user daemon-reload
systemctl --user restart image-resize-daemon.service
```

Check logs:

```bash
journalctl --user -u image-resize-daemon.service -f
```
