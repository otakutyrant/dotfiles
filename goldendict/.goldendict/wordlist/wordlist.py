#!/usr/bin/env python3.8

from collections import defaultdict
from pathlib import Path
import sys

import sh


oxford_pathname = Path.home() / '.goldendict/wordlist/oxford5000.txt'
lemma_pathname = Path.home() / '.goldendict/lemma.en.txt'


def word_to_lemma(word: str):
    result = None
    try:
        _ = sh.egrep(f'([^-\']|^){word}([^-\']|$)', str(lemma_pathname))
        result = sh.egrep(f'\\b{word}\\b', _in=_)
    except sh.ErrorReturnCode_1:
        return None
    else:
        if '/' in result:
            lemma = result.split(' ')[0].split('/')[0]
        else:
            lemma = result.split(' ')[0]
        return lemma


def oxford(keyword: str) -> str:
    try:
        record = sh.egrep(
                f'\\b{keyword}\\b', str(oxford_pathname)
        ).stdout.decode()
    except sh.ErrorReturnCode_1:
        return ""
    else:
        return record


def main():
    words = defaultdict(list)
    directory = Path(sys.argv[0]).parent
    keyword = sys.argv[1]
    lemma = word_to_lemma(keyword)
    if lemma is not None:
        keyword = lemma
    print(oxford(keyword))
    for pathname in directory.glob('*.txt'):
        if pathname.name != oxford_pathname.name:
            with open(pathname) as file_:
                for line in file_:
                    words[line.strip()].append(str(pathname.stem))
    if keyword in words.keys():
        print('\n'.join(words[keyword]))


if __name__ == '__main__':
    main()
