#!/bin/env python
import sys
from pathlib import Path

import pysrt
from pysrt import SubRipFile, SubRipItem


def function(pathname):
    subs = pysrt.open(str(pathname))
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
    new_subs.save(str(pathname), encoding="utf-8")


if __name__ == "__main__":
    pathnames = [Path(argv) for argv in sys.argv[1:]]
    for pathname in pathnames:
        function(pathname)
