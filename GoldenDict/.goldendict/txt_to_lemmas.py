#!/bin/env python

from collections import Counter
from pathlib import Path


def filter_to_valid_words(file_):
    words = [
        word
        for line in file_
        for word in line.split()
        if word.isalpha() and word.isascii()
    ]
    return words


def discard_duplicate_words(words):
    set_ = set(words)
    words = [word.lower() if word.lower() in set_ else word for word in words]
    return words


def discard_capital_words(words):
    words = [word for word in words if word.islower()]
    return words


def main():
    hashmap = {}
    lemma_pathname = Path.home() / ".goldendict/lemma.en.txt"
    with open(lemma_pathname) as lemma_file:
        for line in lemma_file:
            lemma, _, inflections = line.strip().split(" ")
            lemma = lemma.split("/")[0]
            hashmap[lemma] = lemma
            inflections = inflections.split(",")
            for inflection in inflections:
                hashmap[inflection] = lemma
    for pathname in (Path.home() / "Calibre Library").glob("**/*.txt"):
        if pathname.name != "lemmas.txt":
            lemma_pathname = pathname.parent / "lemmas.txt"
            with open(pathname) as file_, open(
                lemma_pathname, "w"
            ) as lemma_file:
                words = filter_to_valid_words(file_)
                words = discard_duplicate_words(words)
                words = discard_capital_words(words)

                lemmas = [hashmap.get(word, word) for word in words]
                counter = Counter(lemmas)
                for word, count in counter.most_common():
                    lemma_file.write(f"{word} {count}\n")
            print(f"{pathname} done.")


if __name__ == "__main__":
    main()
