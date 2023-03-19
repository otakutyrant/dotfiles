#!/bin/env python

import itertools
import re
import sys
from pathlib import Path

from yattag import Doc

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


def search_from_directory(
    directory: Path, keyword: str, suffix: str, doc, tag, text
):
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
            with tag("details"):
                with tag("summary"):
                    doc.asis(f"{pathname.stem} <b>{count}</b>")
                for line in lines:
                    line = re.sub(f"({pattern})", r"<b>\1</b>", line).strip()
                    doc.asis(line)
                    doc.stag("br")
                    doc.stag("br")


def main():
    keyword = sys.argv[1]

    calibre_directory = Path.home() / "Calibre Library"
    doc, tag, text = Doc().tagtext()

    doc.asis("<!DOCTYPE html>")
    with tag("html"):
        with tag("body"):
            search_from_directory(
                calibre_directory, keyword, "txt", doc, tag, text
            )
    print(doc.getvalue())


if __name__ == "__main__":
    main()
