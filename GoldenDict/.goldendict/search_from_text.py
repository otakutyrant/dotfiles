#!/bin/env python

import itertools
import re
import sys
from pathlib import Path

lemma_pathname = Path.home() / ".goldendict/lemma.en.txt"
lemma_file = open(lemma_pathname)


def word_to_inflections(word: str):
    for line in lemma_file:
        match = re.search(rf"(?=[^-\']|^)\b{word}\b(?=[^-\']|$)", line)
        if match:
            lemma = line.split(" ")[0].split("/")[0]
            inflections = line.split()[-1].split(",")
            if lemma not in inflections:
                inflections.insert(0, lemma)
            else:
                index = inflections.index(lemma)
                inflections[0], inflections[index] = (
                    inflections[index],
                    inflections[0],
                )
            return inflections
    return None


def words_to_keyword(words) -> str:
    return " ".join(words)


def search_from_directory(directory: Path, keyword: str, suffix: str) -> str:
    combinations = []
    words = keyword.split(" ")
    for word in words:
        inflections = word_to_inflections(word)
        if inflections is None:
            combinations.append((word,))
        else:
            combinations.append(inflections)
    keywords = [
        words_to_keyword(words)
        for words in list(itertools.product(*combinations))
    ]
    pattern = "\\b({})\\b".format("|".join(keywords))
    record = ""

    for pathname in directory.rglob(f"*.{suffix}"):
        if "lemma" in pathname.name or "deck" in pathname.name:
            continue
        lines = []
        with open(pathname) as file_:
            for line in file_:
                if re.search(pattern, line):
                    lines.append(line)
        count = len(lines)
        if count > 0:
            record += "<details>"
            record += f"<summary>{pathname.stem} <b>{count}</b></summary>"
            for line in lines:
                record += re.sub(f"({pattern})", r"<b>\1</b>", line).strip()
                record += "<br>"
                record += "<br>"
            record += "</details>"
    return record


def main():
    keyword = sys.argv[1]
    record = """<!DOCTYPE html>
<html>
<body>
"""
    calibre_directory = Path.home() / "Calibre Library"
    record += search_from_directory(calibre_directory, keyword, suffix="txt")
    record += """</body>
</html>"""
    print(record)


if __name__ == "__main__":
    main()
