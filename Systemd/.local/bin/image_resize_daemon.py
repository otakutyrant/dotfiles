#!/usr/bin/env python3
from __future__ import annotations

import argparse
import logging
import os
import signal
import sys
import time
from dataclasses import dataclass
from pathlib import Path
from tempfile import NamedTemporaryFile

from PIL import Image, ImageOps, UnidentifiedImageError


SUPPORTED_EXTENSIONS = {
    ".jpg",
    ".jpeg",
    ".png",
    ".webp",
    ".bmp",
    ".tif",
    ".tiff",
}

DEFAULT_ROOT = Path("/home/otakutyrant")
DEFAULT_SHORT_SIDE = 800
DEFAULT_INTERVAL = 5


@dataclass(frozen=True)
class FileState:
    size: int
    mtime_ns: int


class ResizeDaemon:
    def __init__(self, root: Path, target_short_side: int, interval: int) -> None:
        self.root = root
        self.target_short_side = target_short_side
        self.interval = interval
        self._running = True
        self._known_states: dict[Path, FileState] = {}
        self._recently_resized: dict[Path, FileState] = {}

    def stop(self, *_args: object) -> None:
        self._running = False

    def run(self) -> int:
        logging.info(
            "Watching %s for images whose shortest side is below %spx",
            self.root,
            self.target_short_side,
        )
        while self._running:
            self.scan_once()
            if not self._running:
                break
            time.sleep(self.interval)
        logging.info("Stopped")
        return 0

    def scan_once(self) -> None:
        current_paths: set[Path] = set()

        for entry in self.root.iterdir():
            path = entry
            if not self._is_supported_image(path):
                continue

            current_paths.add(path)

            try:
                stat = path.stat()
            except FileNotFoundError:
                continue

            state = FileState(size=stat.st_size, mtime_ns=stat.st_mtime_ns)
            if self._known_states.get(path) == state:
                continue

            if self._recently_resized.get(path) == state:
                self._known_states[path] = state
                continue

            self._process_image(path, state)

        deleted_paths = set(self._known_states) - current_paths
        for path in deleted_paths:
            self._known_states.pop(path, None)
            self._recently_resized.pop(path, None)

    def _is_supported_image(self, path: Path) -> bool:
        return (
            path.is_file()
            and path.name.startswith("202")
            and path.suffix.lower() in SUPPORTED_EXTENSIONS
        )

    def _process_image(self, path: Path, state: FileState) -> None:
        try:
            with Image.open(path) as image:
                source_format = image.format
                if getattr(image, "is_animated", False):
                    logging.debug("Skipping animated image: %s", path)
                    self._known_states[path] = state
                    return

                image = ImageOps.exif_transpose(image)
                width, height = image.size
                short_side = min(width, height)
                if short_side >= self.target_short_side:
                    self._known_states[path] = state
                    return

                scale = self.target_short_side / short_side
                new_size = (
                    max(1, round(width * scale)),
                    max(1, round(height * scale)),
                )
                resized = image.resize(new_size, Image.Resampling.LANCZOS)
                self._save_resized(path, resized, source_format)
        except (UnidentifiedImageError, OSError) as exc:
            logging.warning("Skipping unreadable image %s: %s", path, exc)
            self._known_states[path] = state
            return

        try:
            new_stat = path.stat()
        except FileNotFoundError:
            return

        new_state = FileState(size=new_stat.st_size, mtime_ns=new_stat.st_mtime_ns)
        self._known_states[path] = new_state
        self._recently_resized[path] = new_state
        logging.info("Resized %s", path)

    def _save_resized(self, path: Path, resized: Image.Image, source_format: str | None) -> None:
        suffix = path.suffix or ".img"
        with NamedTemporaryFile(dir=path.parent, prefix=f".{path.stem}-", suffix=suffix, delete=False) as tmp:
            temp_path = Path(tmp.name)

        save_kwargs: dict[str, object] = {}
        if source_format == "JPEG" and resized.mode not in {"RGB", "L"}:
            resized = resized.convert("RGB")
        if source_format == "JPEG":
            save_kwargs["quality"] = 90
            save_kwargs["optimize"] = True
        elif source_format == "PNG":
            save_kwargs["optimize"] = True

        try:
            resized.save(temp_path, format=source_format, **save_kwargs)
            os.replace(temp_path, path)
        finally:
            if temp_path.exists():
                temp_path.unlink(missing_ok=True)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Watch a directory tree and resize images whose shortest side is below a target."
    )
    parser.add_argument("--root", type=Path, default=DEFAULT_ROOT, help="Directory tree to watch")
    parser.add_argument(
        "--target-short-side",
        type=int,
        default=DEFAULT_SHORT_SIDE,
        help="Resize images so their shortest side becomes this many pixels",
    )
    parser.add_argument(
        "--interval",
        type=int,
        default=DEFAULT_INTERVAL,
        help="Seconds between scans in daemon mode",
    )
    parser.add_argument("--once", action="store_true", help="Run one scan and exit")
    parser.add_argument(
        "--verbose",
        action="store_true",
        help="Enable verbose logging",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()

    logging.basicConfig(
        level=logging.DEBUG if args.verbose else logging.INFO,
        format="%(asctime)s %(levelname)s %(message)s",
    )

    if args.target_short_side <= 0:
        logging.error("--target-short-side must be greater than zero")
        return 2

    if args.interval <= 0:
        logging.error("--interval must be greater than zero")
        return 2

    root = args.root.expanduser().resolve()
    if not root.exists():
        logging.error("Root path does not exist: %s", root)
        return 2

    daemon = ResizeDaemon(root=root, target_short_side=args.target_short_side, interval=args.interval)
    signal.signal(signal.SIGINT, daemon.stop)
    signal.signal(signal.SIGTERM, daemon.stop)

    if args.once:
        daemon.scan_once()
        return 0

    return daemon.run()


if __name__ == "__main__":
    sys.exit(main())
