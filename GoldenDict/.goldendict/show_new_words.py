#!/bin/env python

import re
from collections import Counter
from pathlib import Path


def main():
    learnt_words_pathname = (
        Path.home() / "Calibre Library" / "Learnt Words" / "lemmas.txt"
    )
    set_ = set()
    with open(learnt_words_pathname) as file_:
        for line in file_:
            word = re.split(r"\W+", line, 1)[0]
            set_.add(word)
    pathname = Path(
        "/home/otakutyrant/Calibre Library/Frank Herbert/Dune (56)/lemmas.txt"
    )
    counter = Counter()
    with open(pathname) as file_:
        for line in file_:
            word, count = line.split()
            counter[word] = int(count)
    for word in set_:
        del counter[word]
    with open("new_words.txt", "w") as new_words_file:
        for word, count in counter.most_common():
            new_words_file.write(f"{word} {count}\n")


if __name__ == "__main__":
    main()
