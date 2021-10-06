#!/bin/env python

from collections import Counter
from functools import partial
import itertools
from pathlib import Path
import re
import sys

lemma_pathname = Path.home() / '.goldendict/lemma.en.txt'
lemma_file = open(lemma_pathname)


def word_to_inflections(word: str):
    lemma_file.seek(0)
    for line in lemma_file:
        match = re.search(rf'(?=[^-\']|^)\b{word.lower()}\b(?=[^-\']|$)', line)
        if match:
            lemma = line.split(' ')[0].split('/')[0]
            inflections = line.split()[-1].split(',')
            if lemma not in inflections:
                inflections.insert(0, lemma)
            else:
                index = inflections.index(lemma)
                inflections[0], inflections[index] = inflections[index], inflections[0]
            return inflections
    return [word]


def main():
    pathname = Path(sys.argv[1])
    directory = pathname.parent
    lemmas = Counter()
    with open(pathname) as file_:
        for index, line in enumerate(file_):
            for word in line.split():
                if word.isalpha():
                    lemma = word_to_inflections(word)[0]
                    lemmas[lemma] += 1
            if index % 10 == 0:
                print(index)
    with open(directory / 'lemmas.txt', 'w') as lemma_file:
        for key, value in lemmas.most_common():
            lemma_file.write(f'{key} {value}\n')


if __name__ == '__main__':
    main()
