#!/bin/env python

import itertools
import re
import sys
from pathlib import Path
from typing import List

from yattag import Doc

lemma_pathname = Path.home() / ".goldendict/lemma.en.txt"
lemma_file = open(lemma_pathname)


def word_to_inflections(word: str) -> List[str]:
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
    else:
        return [word]


def words_to_keyword(words) -> str:
    return " ".join(words)


# to support searching all cases of the keywrod
def augment_to_all_cases(inflections):
    lowers = [inflection.lower() for inflection in inflections]
    uppers = [inflection.upper() for inflection in inflections]
    capitals = [
        inflection[0].upper() + inflection[1:].lower()
        for inflection in inflections
    ]
    return lowers + uppers + capitals


def keyword_to_pattern(keyword: str, search_raw_keyword) -> str:
    if search_raw_keyword:
        keywords = [keyword]
    else:
        words = keyword.split(" ")
        combinations = []
        for word in words:
            inflections = word_to_inflections(word)
            inflections = augment_to_all_cases(inflections)
            combinations.append(inflections)
        keywords = [
            words_to_keyword(words)
            for words in list(itertools.product(*combinations))
        ]
    pattern = "\\b({})\\b".format("|".join(keywords))
    return pattern


def search_from_directory(
    directory: Path,
    keyword: str,
    suffix: str,
    doc,
    tag,
    text,
    search_raw_keyword,
):
    pattern = keyword_to_pattern(keyword, search_raw_keyword)
    for pathname in directory.rglob(f"*.{suffix}"):
        if pathname.parent.name[:5] == pathname.stem[:5]:
            # Due to the directory name is incomplete unexpectedly,
            # I have to compare slices of them.
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
                        line = re.sub(
                            f"({pattern})", r"<b>\1</b>", line
                        ).strip()
                        doc.asis(line)
                        doc.stag("br")
                        doc.stag("br")


def main():
    arguments = sys.argv[1].split(" ")
    if len(arguments) >= 2 and arguments[-1] == "--no-inflection":
        search_raw_keyword = True
        keyword = " ".join(arguments[:-1])
    else:
        search_raw_keyword = False
        keyword = sys.argv[1]

    calibre_directory = Path.home() / "Calibre Library"
    doc, tag, text = Doc().tagtext()

    doc.asis("<!DOCTYPE html>")
    with tag("html"):
        with tag("body"):
            search_from_directory(
                calibre_directory,
                keyword,
                "txt",
                doc,
                tag,
                text,
                search_raw_keyword,
            )
    print(doc.getvalue())


if __name__ == "__main__":
    main()
