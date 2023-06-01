#!/bin/env python
import sys
from pathlib import Path

import pysrt
import sh
from pysrt import SubRipFile, SubRipItem


def handle(srt_pathname):
    subs = pysrt.open(str(srt_pathname))
    stack = []
    for sub in subs:
        if stack and stack[-1].text[-1].isalpha():
            head = stack.pop()
            tail = sub
            new_text = head.text + " " + tail.text
            merged_sub = SubRipItem(
                len(stack) + 1, head.start, tail.end, new_text
            )
            stack.append(merged_sub)
        else:
            sub.index = len(stack) + 1
            stack.append(sub)
    new_subs = SubRipFile(items=stack)
    new_subs.save(str(srt_pathname), encoding="utf-8")


if __name__ == "__main__":
    video_pathnames = [Path(argv) for argv in sys.argv[1:]]
    for video_pathname in video_pathnames:
        sh.whisper(
            "--output_format",
            "srt",
            str(video_pathname),
            _out=sys.stdout,
            _err=sys.stderr,
        )
        srt_pathname = video_pathname.with_suffix(".srt")
        handle(srt_pathname)
